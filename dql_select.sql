-- Productos con empresa asociada y precio mínimo por ciudad
SELECT c.name AS ciudad, p.name AS producto, co.name AS empresa, MIN(cp.price) AS precio_minimo
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
JOIN companies co ON cp.company_id = co.id
JOIN citiesormunicipalities c ON co.city_id = c.id
GROUP BY c.name, p.name, co.name
ORDER BY c.name, precio_minimo;

-- Top 5 clientes que más productos han calificado en los últimos 6 meses
SELECT c.name AS cliente, COUNT(qp.product_id) AS total_calificaciones
FROM customers c
JOIN quality_products qp ON c.id = qp.customer_id
WHERE qp.daterating >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY c.id
ORDER BY total_calificaciones DESC
LIMIT 5;

-- Distribución de productos por categoría y unidad de medida
SELECT cat.description AS categoria, um.description AS unidad_medida, COUNT(p.id) AS cantidad
FROM products p
JOIN categories cat ON p.category_id = cat.id
JOIN companyproducts cp ON p.id = cp.product_id
JOIN unitofmeasure um ON cp.unitmeasure_id = um.id
GROUP BY cat.description, um.description
ORDER BY cantidad DESC;

-- Productos con calificaciones superiores al promedio general
SELECT p.name AS producto, AVG(qp.rating) AS calificacion_promedio
FROM products p
JOIN quality_products qp ON p.id = qp.product_id
GROUP BY p.id
HAVING calificacion_promedio > (SELECT AVG(rating) FROM quality_products)
ORDER BY calificacion_promedio DESC;

-- Empresas que no han recibido ninguna calificación
SELECT co.name AS empresa
FROM companies co
LEFT JOIN quality_products qp ON co.id = qp.company_id
WHERE qp.id IS NULL;

-- Productos añadidos como favoritos por más de 10 clientes
SELECT p.name AS producto, COUNT(DISTINCT f.customer_id) AS total_clientes
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
GROUP BY p.id
HAVING total_clientes > 10
ORDER BY total_clientes DESC;

-- Empresas activas por ciudad y categoría
SELECT ci.name AS ciudad, cat.description AS categoria, COUNT(co.id) AS total_empresas
FROM companies co
JOIN citiesormunicipalities ci ON co.city_id = ci.id
JOIN categories cat ON co.category_id = cat.id
GROUP BY ci.name, cat.description
ORDER BY ci.name, total_empresas DESC;

-- 10 productos más calificados en cada ciudad
WITH RankedProducts AS (
    SELECT ci.name AS ciudad, p.name AS producto, COUNT(qp.id) AS total_calificaciones, ROW_NUMBER() OVER (PARTITION BY ci.name ORDER BY COUNT(qp.id) DESC) AS ranking
    FROM products p
    JOIN quality_products qp ON p.id = qp.product_id
    JOIN companies co ON qp.company_id = co.id
    JOIN citiesormunicipalities ci ON co.city_id = ci.id
    GROUP BY ci.name, p.name
)
SELECT ciudad, producto, total_calificaciones
FROM RankedProducts
WHERE ranking <= 10
ORDER BY ciudad, total_calificaciones DESC;

-- Productos sin unidad de medida asignada
SELECT p.name AS producto
FROM products p
LEFT JOIN companyproducts cp ON p.id = cp.product_id
WHERE cp.unitmeasure_id IS NULL;

-- Planes de membresía sin beneficios registrados
SELECT m.name AS membresia
FROM memberships m
LEFT JOIN membershipbenefits mb ON m.id = mb.membership_id
WHERE mb.membership_id IS NULL;

-- Productos de una categoría específica con su promedio de calificación
SELECT p.name AS producto, AVG(qp.rating) AS calificacion_promedio
FROM products p
JOIN quality_products qp ON p.id = qp.product_id
WHERE p.category_id = 1
GROUP BY p.id
ORDER BY calificacion_promedio DESC;

-- Clientes que han comprado productos de más de una empresa
SELECT c.name AS cliente, COUNT(DISTINCT qp.company_id) AS empresas_distintas
FROM customers c
JOIN quality_products qp ON c.id = qp.customer_id
GROUP BY c.id
HAVING empresas_distintas > 1
ORDER BY empresas_distintas DESC;

-- Ciudades con más clientes activos
SELECT ci.name AS ciudad, COUNT(c.id) AS total_clientes
FROM customers c
JOIN citiesormunicipalities ci ON c.city_id = ci.id
GROUP BY ci.name
ORDER BY total_clientes DESC
LIMIT 10;

-- Ranking de productos por empresa basado en la media de quality_products
SELECT co.name AS empresa, p.name AS producto, AVG(qp.rating) AS calificacion_promedio, RANK() OVER (PARTITION BY co.name ORDER BY AVG(qp.rating) DESC) AS ranking
FROM products p
JOIN quality_products qp ON p.id = qp.product_id
JOIN companies co ON qp.company_id = co.id
GROUP BY co.name, p.name
ORDER BY co.name, ranking;

-- Empresas que ofrecen más de cinco productos distintos
SELECT co.name AS empresa, COUNT(cp.product_id) AS total_productos
FROM companies co
JOIN companyproducts cp ON co.id = cp.company_id
GROUP BY co.id
HAVING total_productos > 5
ORDER BY total_productos DESC;

-- Productos favoritos que aún no han sido calificados
SELECT p.name AS producto_favorito, c.name AS cliente
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
JOIN customers c ON f.customer_id = c.id
LEFT JOIN quality_products qp ON p.id = qp.product_id AND qp.customer_id = c.id
WHERE qp.id IS NULL;

-- Beneficios asignados a cada audiencia con descripción
SELECT a.description AS audiencia, b.description AS beneficio, b.detail AS detalle
FROM audiences a
JOIN audiencebenefits ab ON a.id = ab.audience_id
JOIN benefits b ON ab.benefit_id = b.id
ORDER BY a.description, b.description;

-- Ciudades con empresas sin productos asociados
SELECT DISTINCT ci.name AS ciudad
FROM companies co
JOIN citiesormunicipalities ci ON co.city_id = ci.id
LEFT JOIN companyproducts cp ON co.id = cp.company_id
WHERE cp.id IS NULL;

-- Empresas con productos duplicados por nombre
SELECT co.name AS empresa, p.name AS producto_duplicado, COUNT(*) AS ocurrencias
FROM products p
JOIN companyproducts cp ON p.id = cp.product_id
JOIN companies co ON cp.company_id = co.id
GROUP BY co.name, p.name
HAVING ocurrencias > 1
ORDER BY ocurrencias DESC;

-- Vista resumen de clientes, productos favoritos y promedio de calificación
SELECT c.name AS cliente, COUNT(DISTINCT f.id) AS total_favoritos, COUNT(DISTINCT qp.product_id) AS productos_calificados, AVG(qp.rating) AS calificacion_promedio
FROM customers c
LEFT JOIN favorites f ON c.id = f.customer_id
LEFT JOIN quality_products qp ON c.id = qp.customer_id
GROUP BY c.id
ORDER BY calificacion_promedio DESC;
