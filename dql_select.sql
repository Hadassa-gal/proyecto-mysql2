--Como analista, quiero listar todos los productos con su empresa asociada y el precio más bajo por ciudad.
SELECT p.name AS product, c.name AS company, p.price, cm.name AS city
FROM companyproducts cp
JOIN products p ON cp.product_id = p.id
JOIN companies c ON cp.company_id = c.id
JOIN citiesormunicipalities cm ON cm.id = c.city_id
ORDER BY p.price;

