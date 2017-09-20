CREATE USER admin_db WITH PASSWORD '123';
CREATE DATABASE learndb;
GRANT ALL PRIVILEGES ON DATABASE learndb TO admin_db;

CREATE TABLE category (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE subcategory(
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(50),
  category_id INT REFERENCES category(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE promotion(
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  discount INT NOT NULL,
  date_beginning DATE NOT NULL,
  date_ending DATE NOT NULL
);

CREATE TABLE product(
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(60) NOT NULL,
  price INT NOT NULL,
  country VARCHAR(30) NOT NULL,
  description TEXT NOT NULL,
  photo_url VARCHAR(255) NOT NULL,
  subcategory_id INT REFERENCES subcategory(id) ON DELETE CASCADE NOT NULL,
  in_stock SMALLINT NOT NULL,
  promotion_id INT REFERENCES promotion(id) ON DELETE NO ACTION NULL
);

CREATE TYPE sex AS ENUM ('male', 'female');
CREATE TABLE customer(
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(30) NOT NULL,
  surname VARCHAR(30) NOT NULL,
  sex sex NOT NULL,
  birthday DATE,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255),
  regular_customer SMALLINT NOT NULL
);

CREATE TABLE address(
  id SERIAL PRIMARY KEY NOT NULL,
  city VARCHAR(50) NOT NULL,
  street VARCHAR(100) NOT NULL,
  house VARCHAR(10) NOT NULL,
  apartment INT,
  customer_id INT REFERENCES customer(id) ON DELETE NO ACTION NOT NULL
);

CREATE TABLE currency(
  id SERIAL PRIMARY KEY NOT NULL,
  code VARCHAR(30) NOT NULL,
  name VARCHAR(30),
  usd_rate FLOAT NOT NULL
);

CREATE TYPE payment_name AS ENUM ('cash', 'card');
CREATE TABLE payment_type(
  id SERIAL PRIMARY KEY NOT NULL,
  name payment_name NOT NULL
);

CREATE TYPE order_status AS ENUM ('new', 'in processing', 'sent');
CREATE TABLE customer_order(
  id SERIAL PRIMARY KEY NOT NULL,
  customer_id INT REFERENCES customer(id) ON DELETE NO ACTION NOT NULL,
  status order_status NOT NULL,
  sum INT NOT NULL,
  currency_id INT REFERENCES currency(id) NOT NULL,
  comment TEXT,
  date DATE NOT NULL,
  payment_type_id INT REFERENCES payment_type(id) NOT NULL
);

CREATE TABLE basket(
  id SERIAL PRIMARY KEY NOT NULL,
  product_id INT REFERENCES product(id) NOT NULL,
  order_id INT REFERENCES customer_order(id) NOT NULL,
  count INT NOT NULL,
  date DATE NOT NULL,
  sum INT NOT NULL
);

CREATE TYPE delivery_status AS ENUM ('new', 'in processing', 'delivered');
CREATE TYPE delivery_method AS ENUM ('nova poshta', 'courier', 'pickup from warehouse');
CREATE TABLE delivery(
  id SERIAL PRIMARY KEY NOT NULL,
  order_id INT REFERENCES customer_order(id) ON DELETE NO ACTION NOT NULL,
  address_id INT REFERENCES address(id) ON DELETE NO ACTION NOT NULL,
  delivery_sum INT NOT NULL,
  total_sum INT NOT NULL,
  status delivery_status NOT NULL,
  method delivery_method NOT NULL,
  time TIMESTAMP
);

CREATE TABLE provider(
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  contract VARCHAR(255) NOT NULL
);

CREATE TABLE supply(
  id SERIAL PRIMARY KEY NOT NULL,
  product_id INT REFERENCES product(id) ON DELETE NO ACTION NOT NULL,
  provider_id INT REFERENCES provider(id) ON DELETE NO ACTION NOT NULL,
  count INT NOT NULL,
  sum FLOAT NOT NULL
);

ALTER TABLE product ADD COLUMN brend VARCHAR(30);
ALTER TABLE supply ADD COLUMN date DATE;