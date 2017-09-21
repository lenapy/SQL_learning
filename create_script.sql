CREATE USER admin_db WITH PASSWORD '123';
CREATE DATABASE shop;
GRANT ALL PRIVILEGES ON DATABASE shop TO admin_db;

CREATE TABLE IF NOT EXISTS category (
  id SERIAL,
  name VARCHAR(50) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS subcategory(
  id SERIAL,
  name VARCHAR(50),
  category_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE

);

CREATE TABLE IF NOT EXISTS promotion(
  id SERIAL,
  name VARCHAR(255) NOT NULL,
  discount INT NOT NULL,
  date_beginning DATE NOT NULL,
  date_ending DATE NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product(
  id SERIAL,
  name VARCHAR(60) NOT NULL,
  price INT NOT NULL,
  country VARCHAR(30) NOT NULL,
  description TEXT NOT NULL,
  photo_url VARCHAR(255) NOT NULL,
  subcategory_id INT NOT NULL,
  in_stock SMALLINT NOT NULL DEFAULT 1,
  promotion_id INT,
  PRIMARY KEY (id),
  FOREIGN KEY (subcategory_id) REFERENCES subcategory(id) ON DELETE CASCADE,
  FOREIGN KEY (promotion_id) REFERENCES promotion(id) ON DELETE SET NULL
);

CREATE TYPE sex_enum AS ENUM ('male', 'female');
CREATE TABLE IF NOT EXISTS customer(
  id SERIAL,
  name VARCHAR(30) NOT NULL,
  surname VARCHAR(30) NOT NULL,
  sex sex_enum NOT NULL,
  birthday DATE,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255),
  regular_customer SMALLINT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS address(
  id SERIAL,
  city VARCHAR(50) NOT NULL,
  street VARCHAR(100) NOT NULL,
  house VARCHAR(10) NOT NULL,
  apartment INT,
  customer_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS currency(
  id SERIAL,
  code VARCHAR(30) NOT NULL,
  name VARCHAR(30),
  usd_rate FLOAT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TYPE payment_name AS ENUM ('cash', 'card');
CREATE TABLE IF NOT EXISTS payment_type(
  id SERIAL,
  name payment_name NOT NULL,
  PRIMARY KEY (id)
);

CREATE TYPE order_status AS ENUM ('new', 'in processing', 'sent');
CREATE TABLE IF NOT EXISTS customer_order(
  id SERIAL,
  customer_id INT NOT NULL,
  status order_status NOT NULL,
  sum INT NOT NULL,
  currency_id INT NOT NULL,
  comment TEXT,
  date DATE NOT NULL,
  payment_type_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE SET NULL,
  FOREIGN KEY (currency_id) REFERENCES currency(id)ON DELETE SET NULL,
  FOREIGN KEY (payment_type_id) REFERENCES payment_type(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS basket(
  id SERIAL,
  product_id INT NOT NULL,
  order_id INT NOT NULL,
  count INT NOT NULL,
  date DATE NOT NULL,
  sum INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE SET NULL,
  FOREIGN KEY (order_id)REFERENCES customer_order(id) ON DELETE SET NULL
);

CREATE TYPE delivery_status AS ENUM ('new', 'in processing', 'delivered');
CREATE TYPE delivery_method AS ENUM ('nova poshta', 'courier', 'pickup from warehouse');
CREATE TABLE IF NOT EXISTS delivery(
  id SERIAL,
  order_id INT NOT NULL UNIQUE,
  address_id INT NOT NULL,
  delivery_sum INT NOT NULL,
  total_sum INT NOT NULL,
  status delivery_status NOT NULL,
  method delivery_method NOT NULL,
  time TIMESTAMP NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (order_id) REFERENCES customer_order(id) ON DELETE SET NULL,
  FOREIGN KEY (address_id) REFERENCES address(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS provider(
  id SERIAL,
  name VARCHAR(255) NOT NULL,
  contract VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS supply(
  id SERIAL,
  product_id INT NOT NULL,
  provider_id INT NOT NULL,
  count INT NOT NULL,
  sum FLOAT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY(product_id) REFERENCES product(id) ON DELETE SET NULL,
  FOREIGN KEY(provider_id) REFERENCES provider(id) ON DELETE SET NULL

);

CREATE TABLE IF NOT EXISTS promotions_product(
  id SERIAL,
  product_id INT NOT NULL,
  promotion_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY(product_id) REFERENCES product(id) ON DELETE SET NULL,
  FOREIGN KEY(promotion_id) REFERENCES provider(id) ON DELETE SET NULL
);

ALTER TABLE product ADD COLUMN brand VARCHAR(30);
ALTER TABLE supply ADD COLUMN date DATE;
ALTER TABLE product DROP COLUMN IF EXISTS promotion_id;

SELECT name, surname, birthday
FROM customer
WHERE regular_customer = 1
      AND  EXTRACT(month FROM now()) = EXTRACT(month FROM birthday);

SELECT id, name, date_ending
FROM promotion
WHERE date_ending = 'today'::date + interval '7 day';

SELECT provider.id, provider.name, supply.date
FROM provider
  JOIN supply ON provider.id = supply.provider_id
WHERE supply.date BETWEEN 'today'::date - interval '3 month' AND 'today'::date;

SELECT product.id, product.name, basket.product_id, basket.date
FROM product
  LEFT JOIN  basket ON product.id = basket.product_id
WHERE basket.date NOT BETWEEN 'today'::date - interval '1 month' AND 'today'::date
      OR basket.date ISNULL;


SELECT product.id, product.name
FROM product
LEFT JOIN promotions_product ON product.id = promotions_product.product_id
WHERE promotion_id ISNULL;

SELECT provider.name, supply.date
FROM provider
  LEFT JOIN supply ON provider.id = supply.provider_id
WHERE supply.date NOT BETWEEN 'today'::date - interval '1 month' AND 'today'::date
      OR supply.date ISNULL;

SELECT customer.id, customer.name, customer.surname
FROM customer
  LEFT JOIN customer_order ON customer.id = customer_order.customer_id
WHERE customer.regular_customer = 1
      AND customer_order.date NOT BETWEEN 'today'::date - interval '1 month' AND 'today'::date
      OR customer_order.date ISNULL;

SELECT product.name AS product_name, promotion.name AS promotion_name
FROM product
JOIN promotions_product ON product.id = promotions_product.product_id
JOIN promotion ON promotion.id = promotions_product.promotion_id
LEFT JOIN basket ON product.id = basket.product_id
WHERE basket.sum ISNULL AND (basket.date BETWEEN promotion.date_beginning AND promotion.date_ending OR basket.date ISNULL);

SELECT product.brand, sum(basket.sum)
from basket
JOIN product ON basket.product_id = product.id
WHERE product.subcategory_id = 1
      AND basket.date BETWEEN 'today'::date - interval '1 month' AND 'today'::date
GROUP BY product.brand;

SELECT category.name, sum(basket.sum)
from basket
JOIN product ON basket.product_id = product.id
JOIN subcategory ON product.subcategory_id = subcategory.id
JOIN category ON subcategory.category_id = category.id
WHERE basket.date BETWEEN 'today'::date - interval '1 month' AND 'today'::date
GROUP BY category.id;

SELECT product.name, count(basket.product_id), sum(basket.sum)
FROM basket
JOIN product ON basket.product_id = product.id
WHERE basket.date BETWEEN 'today'::date - interval '7 days' AND 'today'::date
GROUP BY product.id;

SELECT to_char(supply.date, 'month') AS month, sum(supply.sum) AS monthly_sum, provider.name
FROM supply
JOIN provider ON supply.provider_id = provider.id
WHERE EXTRACT(YEAR FROM supply.date) = EXTRACT(YEAR FROM now())
GROUP BY provider.id, month;

SELECT product.id, product.name
FROM product
JOIN subcategory ON product.subcategory_id = subcategory.id
JOIN category ON subcategory.category_id = category.id
WHERE category.id = 1 and product.price = 100;

SELECT provider.name
FROM provider
JOIN supply ON provider.id = supply.provider_id
JOIN product ON supply.product_id = product.id
WHERE product.brand = 'White Mandarin'
GROUP BY provider.name;

SELECT product.id, product.name
FROM product
WHERE product.promotion_id IS NOT NULL AND product.brand = 'Chanel';

SELECT product.brand
FROM product
WHERE subcategory_id = 5
GROUP BY brand;

-- SELECT sum_table.name as name,
--   sum_table.surname as surname,
--   max(sum_table.monthly_sum) as max
-- FROM (SELECT customer.name,
--         customer.surname,
--         sum(customer_order.sum) as monthly_sum
-- FROM customer
-- JOIN customer_order ON customer.id = customer_order.customer_id
-- WHERE customer_order.date BETWEEN '2017-09-01' AND now()
-- GROUP BY customer.id) sum_table
-- GROUP BY name, surname
-- ORDER BY  max DESC LIMIT 1;

SELECT customer.name, customer.surname,
        sum(customer_order.sum) as monthly_sum
FROM customer
JOIN customer_order ON customer.id = customer_order.customer_id
WHERE customer_order.date BETWEEN '2017-09-01' AND now()
GROUP BY customer.name, customer.surname
ORDER BY monthly_sum DESC LIMIT 1;

SELECT product.name,product.brand, category.name, count(product.id)
FROM product
JOIN basket ON product.id = basket.product_id
JOIN subcategory ON product.subcategory_id = subcategory.id
JOIN category ON subcategory.category_id = category.id
GROUP BY product.id, category.name
ORDER BY count DESC LIMIT 1;

SELECT provider.name, sum(supply.sum) as sum
FROM provider
JOIN supply ON provider.id = supply.provider_id
WHERE EXTRACT(YEAR FROM supply.date) = EXTRACT(YEAR FROM now())
GROUP BY provider.name
ORDER BY sum DESC LIMIT 1;

SELECT product.name AS product_name, promotion.name AS promotion_name, sum(basket.sum) as sum
FROM product
JOIN promotions_product ON product.id = promotions_product.product_id
JOIN promotion ON promotion.id = promotions_product.promotion_id
JOIN basket ON product.id = basket.product_id
WHERE basket.date BETWEEN 'today'::date - interval '6 month' AND 'today'::date
GROUP BY product.name, promotion.name
ORDER BY sum DESC LIMIT 1;

