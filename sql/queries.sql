-- =======================================================
-- DASHBOARD: E-Commerce Sales & Customer Analytics
-- Target DB: PostgreSQL (Neon.tech)
-- Author: Joel Sosa
-- =======================================================

-- -------------------------------------------------------
-- 1. KPIs SUPERIORES
-- -------------------------------------------------------
-- Ganancias
SELECT 
  SUM(profit) AS "Ganancias"
FROM 
  ecommerce_shair_khan.ecommerce_sales_customer_analytics
WHERE 
  $__timeFilter(order_date::date)
  AND customer_country IN ($country);

--Total de Pedidos
SELECT 
  COUNT(DISTINCT order_id) AS "Total de Pedidos"
FROM 
  ecommerce_shair_khan.ecommerce_sales_customer_analytics
WHERE 
  $__timeFilter(order_date::date)
  AND customer_country IN ($country);

--Nuevos clientes
SELECT 
  COUNT(customer_id) AS "Nuevos clientes"
FROM 
  ecommerce_shair_khan.ecommerce_sales_customer_analytics
WHERE 
  is_repeat_customer = false
  AND $__timeFilter(order_date::date)
  AND customer_country IN ($country);

--Ordenes completadas
SELECT 
  (COUNT(DISTINCT CASE WHEN order_status = 'Completed' THEN order_id END)::numeric / COUNT(DISTINCT order_id)::numeric) AS "Órdenes completadas"
FROM 
  ecommerce_shair_khan.ecommerce_sales_customer_analytics
WHERE 
  $__timeFilter(order_date::date)
  AND customer_country IN ($country);

-- -------------------------------------------------------
-- 2. EVOLUCIÓN TEMPORAL (Doble Eje Y)
-- -------------------------------------------------------
SELECT
  DATE_TRUNC('${time_range}', order_date::timestamp)::date AS time,
  COUNT(quantity) AS "Ventas",
  SUM(profit) AS "Ganancias ($)"
FROM
  ecommerce_shair_khan.ecommerce_sales_customer_analytics
WHERE 
  $__timeFilter(order_date)
  AND customer_country IN ($country) 
GROUP BY 1
ORDER BY 1;

-- -------------------------------------------------------
-- 3. TABLA TOP 5 PRODUCTOS
-- -------------------------------------------------------
SELECT 
  p.product_name AS "Producto", 
  SUM(a.profit) AS "Ganancias",
  COUNT(o.order_id) AS "Ventas",
  COUNT(a.customer_rating) AS "Reseñas",
  AVG(a.customer_rating) AS "Valoración promedio"
FROM 
  ecommerce_shair_khan.ecommerce_sales_customer_analytics AS a
JOIN 
  ecommerce_shair_khan.order_items AS o ON a.order_id = o.order_id
JOIN 
  ecommerce_shair_khan.product_catalog AS p ON o.product_id = p.product_id
WHERE 
  $__timeFilter(a.order_date::date)
  AND customer_country IN ($country)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- -------------------------------------------------------
-- 4. TOP PAISES (Línea base global)
-- -------------------------------------------------------
SELECT 
  customer_country AS "Ubicación", 
  SUM(profit) AS "Ingresos"
FROM 
  ecommerce_shair_khan.ecommerce_sales_customer_analytics
WHERE 
  $__timeFilter(order_date::date)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 6;
