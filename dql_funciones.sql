-- 1. Obtener el promedio de calificación por producto
-- "Como analista, quiero obtener el promedio de calificación por producto."
-- 🔍 Explicación para dummies: La persona encargada de revisar el rendimiento quiere saber qué tan bien calificado está cada producto. Con AVG(rating) agrupado por product_id, puede verlo de forma resumida.
SELECT product_id, ROUND(AVG(rating), 2) AS promedio
FROM quality_products
GROUP BY product_id;

-- 2. Contar cuántos productos ha calificado cada cliente
-- "Como gerente, desea contar cuántos productos ha calificado cada cliente."
-- 🔍 Explicación: Aquí se quiere saber quiénes están activos opinando. Se usa COUNT(*) sobre rates, agrupando por customer_id.
SELECT customer_id, COUNT(*) AS productos_calificados
FROM rates
GROUP BY customer_id;

-- 3. Sumar el total de beneficios asignados por audiencia
-- "Como auditor, quiere sumar el total de beneficios asignados por audiencia."
-- 🔍 Explicación: El auditor busca cuántos beneficios tiene cada tipo de usuario. Con COUNT(*) agrupado por audience_id en audiencebenefits, lo obtiene.
SELECT audience_id, COUNT(*) AS total_beneficios
FROM audiencebenefits
GROUP BY audience_id;

-- 4. Calcular la media de productos por empresa
-- "Como administrador, desea conocer la media de productos por empresa."
-- 🔍 Explicación: El administrador quiere saber si las empresas están ofreciendo pocos o muchos productos. Cuenta los productos por empresa y saca el promedio con AVG(cantidad).
SELECT ROUND(AVG(productos), 2) AS media_productos_por_empresa
FROM (
    SELECT company_id, COUNT(*) AS productos
    FROM companyproducts
    GROUP BY company_id
) AS sub;

-- 5. Contar el total de empresas por ciudad
-- "Como supervisor, quiere ver el total de empresas por ciudad."
-- 🔍 Explicación: La idea es ver en qué ciudades hay más movimiento empresarial. Se usa COUNT(*) en companies, agrupando por city_id.
SELECT city_id, COUNT(*) AS total_empresas
FROM companies
GROUP BY city_id;

-- 6. Calcular el promedio de precios por unidad de medida
-- "Como técnico, desea obtener el promedio de precios de productos por unidad de medida."
-- 🔍 Explicación: Se necesita saber si los precios son coherentes según el tipo de medida. Con AVG(price) agrupado por unit_id, se compara cuánto cuesta el litro, kilo, unidad, etc.
SELECT unitmeasure_id, ROUND(AVG(price), 2) AS promedio_precio
FROM companyproducts
GROUP BY unitmeasure_id;

-- 7. Contar cuántos clientes hay por ciudad
-- "Como gerente, quiere ver el número de clientes registrados por cada ciudad."
-- 🔍 Explicación: Con COUNT(*) agrupado por city_id en la tabla customers, se obtiene la cantidad de clientes que hay en cada zona.
SELECT city_id, COUNT(*) AS total_clientes
FROM customers
GROUP BY city_id;

-- 8. Calcular planes de membresía por periodo
-- "Como operador, desea contar cuántos planes de membresía existen por periodo."
-- 🔍 Explicación: Sirve para ver qué tantos planes están vigentes cada mes o trimestre. Se agrupa por periodo (start_date, end_date) y se cuenta cuántos registros hay.
SELECT period_id, COUNT(*) AS total_planes
FROM membershipperiods
GROUP BY period_id;

-- 9. Ver el promedio de calificaciones dadas por un cliente a sus favoritos
-- "Como cliente, quiere ver el promedio de calificaciones que ha otorgado a sus productos favoritos."
-- 🔍 Explicación: El cliente quiere saber cómo ha calificado lo que más le gusta. Se hace un JOIN entre favoritos y calificaciones, y se saca AVG(rating).
SELECT f.customer_id, ROUND(AVG(r.rating), 2) AS promedio_favoritos
FROM favorites f
JOIN details_favorites df ON f.id = df.favorite_id
JOIN rates r ON f.customer_id = r.customer_id
GROUP BY f.customer_id;

-- 10. Consultar la fecha más reciente en que se calificó un producto
-- "Como auditor, desea obtener la fecha más reciente en la que se calificó un producto."
-- 🔍 Explicación: Busca el MAX(created_at) agrupado por producto. Así sabe cuál fue la última vez que se evaluó cada uno.
SELECT product_id, MAX(daterating) AS ultima_fecha
FROM quality_products
GROUP BY product_id;

-- 11. Obtener la desviación estándar de precios por categoría
-- "Como desarrollador, quiere conocer la variación de precios por categoría de producto."
-- 🔍 Explicación: Usando STDDEV(price) en companyproducts agrupado por category_id, se puede ver si hay mucha diferencia de precios dentro de una categoría.
SELECT p.category_id, STDDEV(cp.price) AS desviacion_precio
FROM companyproducts cp
JOIN products p ON cp.product_id = p.id
GROUP BY p.category_id;

-- 12. Contar cuántas veces un producto fue favorito
-- "Como técnico, desea contar cuántas veces un producto fue marcado como favorito."
-- 🔍 Explicación: Con COUNT(*) en details_favorites, agrupado por product_id, se obtiene cuáles productos son los más populares entre los clientes.
SELECT product_id, COUNT(*) AS veces_favorito
FROM details_favorites
GROUP BY product_id;

-- 13. Calcular el porcentaje de productos evaluados
-- "Como director, quiere saber qué porcentaje de productos han sido calificados al menos una vez."
-- 🔍 Explicación: Cuenta cuántos productos hay en total y cuántos han sido evaluados (rates). Luego calcula (evaluados / total) * 100.
SELECT 
    ROUND((COUNT(DISTINCT product_id) / (SELECT COUNT(*) FROM products)) * 100, 2) 
    AS porcentaje_evaluados
FROM rates;

-- 14. Ver el promedio de rating por encuesta
-- "Como analista, desea conocer el promedio de rating por encuesta."
-- 🔍 Explicación: Agrupa por poll_id en rates, y calcula el AVG(rating) para ver cómo se comportó cada encuesta.
SELECT poll_id, ROUND(AVG(rating), 2) AS promedio_rating
FROM rates
GROUP BY poll_id;

-- 15. Calcular el promedio y total de beneficios por plan
-- "Como gestor, quiere obtener el promedio y el total de beneficios asignados a cada plan de membresía."
-- 🔍 Explicación: Agrupa por membership_id en membershipbenefits, y usa COUNT(*) y AVG(beneficio) si aplica (si hay ponderación).
SELECT membership_id, COUNT(*) AS total_beneficios
FROM membershipbenefits
GROUP BY membership_id;

-- 16. Obtener media y varianza de precios por empresa
-- "Como gerente, desea obtener la media y la varianza del precio de productos por empresa."
-- 🔍 Explicación: Se agrupa por company_id y se usa AVG(price) y VARIANCE(price) para saber qué tan consistentes son los precios por empresa.
SELECT company_id, 
       ROUND(AVG(price), 2) AS media, 
       ROUND(VARIANCE(price), 2) AS varianza
FROM companyproducts
GROUP BY company_id;

-- 17. Ver total de productos disponibles en la ciudad del cliente
-- "Como cliente, quiere ver cuántos productos están disponibles en su ciudad."
-- 🔍 Explicación: Hace un JOIN entre companies, companyproducts y citiesormunicipalities, filtrando por la ciudad del cliente. Luego se cuenta.
SELECT c.city_id, COUNT(DISTINCT cp.product_id) AS total_productos
FROM customers c
JOIN companies co ON c.city_id = co.city_id
JOIN companyproducts cp ON co.id = cp.company_id
GROUP BY c.city_id;

-- 18. Contar productos únicos por tipo de empresa
-- "Como administrador, desea contar los productos únicos por tipo de empresa."
-- 🔍 Explicación: Agrupa por company_type_id y cuenta cuántos productos diferentes tiene cada tipo de empresa.
SELECT t.id AS tipo_empresa, COUNT(DISTINCT cp.product_id) AS productos_unicos
FROM companies c
JOIN typesofidentifications t ON c.type_id = t.id
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY t.id;

-- 19. Ver total de clientes sin correo electrónico registrado
-- "Como operador, quiere saber cuántos clientes no han registrado su correo."
-- 🔍 Explicación: Filtra customers WHERE email IS NULL y hace un COUNT(*). Esto ayuda a mejorar la base de datos para campañas.
SELECT COUNT(*) AS clientes_sin_correo
FROM customers
WHERE email IS NULL OR email = '';

-- 20. Empresa con más productos calificados
-- "Como especialista, desea obtener la empresa con el mayor número de productos calificados."
-- 🔍 Explicación: Hace un JOIN entre companies, companyproducts, y rates, agrupa por empresa y usa COUNT(DISTINCT product_id), ordenando en orden descendente y tomando solo el primero.
SELECT company_id, COUNT(DISTINCT product_id) AS total_calificados
FROM rates
GROUP BY company_id
ORDER BY total_calificados DESC
LIMIT 1;

