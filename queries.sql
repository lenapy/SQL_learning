SELECT name, surname, birthday
FROM customer
WHERE regular_customer = 1
      AND  EXTRACT(month FROM now()) = EXTRACT(month FROM birthday);

SELECT id, name, date_ending
FROM promotion
WHERE date_ending = 'today'::date + interval '7 day';

SELECT provider.name
FROM provider
WHERE provider.id NOT IN (SELECT provider.id
FROM provider
LEFT JOIN supply ON provider.id = supply.provider_id
WHERE supply.date BETWEEN 'today'::date - interval '1 month'
AND 'today'::date);

SELECT product.id, product.name, basket.product_id, basket.date
FROM product
  LEFT JOIN  basket ON product.id = basket.product_id
WHERE basket.date NOT BETWEEN 'today'::date - interval '1 month' AND 'today'::date
      OR basket.date ISNULL;


SELECT product.id, product.name
FROM product
LEFT JOIN promotions_product ON product.id = promotions_product.product_id
LEFT JOIN promotion ON promotions_product.promotion_id = promotion.id
WHERE promotion.id ISNULL
      OR 'today'::date NOT BETWEEN promotion.date_beginning AND promotion.date_ending;

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

SELECT customer.id, product.name, count(basket.product_id), avg(basket.sum)
FROM basket
JOIN product ON basket.product_id = product.id
JOIN customer_order ON basket.order_id = customer_order.id
JOIN customer ON customer_order.customer_id = customer.id
WHERE basket.date BETWEEN 'today'::date - interval '7 days' AND 'today'::date
GROUP BY product.id, customer.id;

SELECT to_char(supply.date, 'month') AS month, sum(supply.sum) AS monthly_sum, provider.name
FROM supply
JOIN provider ON supply.provider_id = provider.id
WHERE EXTRACT(YEAR FROM supply.date) = EXTRACT(YEAR FROM now())
GROUP BY provider.id, month;

SELECT product.id, product.name
FROM product
JOIN subcategory ON product.subcategory_id = subcategory.id
JOIN category ON subcategory.category_id = category.id
WHERE category.name = 'Волосы' and product.price = 100;

SELECT provider.name
FROM provider
JOIN supply ON provider.id = supply.provider_id
JOIN product ON supply.product_id = product.id
WHERE product.brand = 'White Mandarin'
GROUP BY provider.name;

SELECT product.id, product.name
FROM product
JOIN promotions_product ON product.id = promotions_product.product_id
WHERE product.brand = 'Chanel';

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
