--1. Obtener el promedio de calificación por producto
--"Como analista, quiero obtener el promedio de calificación por producto."
--🔍 Explicación para dummies: La persona encargada de revisar el rendimiento quiere saber qué tan bien calificado está cada producto. Con AVG(rating) agrupado por product_id, puede verlo de forma resumida.
DELIMITER //
CREATE PROCEDURE promedio_calificacion_por_producto()
BEGIN
    SELECT 
        p.id AS producto_id,
        p.name AS nombre_producto,
        ROUND(AVG(q.rating), 2) AS promedio_calificacion,
        COUNT(q.rating) AS total_calificaciones
    FROM products p
    JOIN quality_products q ON p.id = q.product_id
    GROUP BY p.id, p.name
    ORDER BY promedio_calificacion DESC;
END //
DELIMITER ;

--2. Insertar empresa y asociar productos por defecto
--"Como administrador, deseo un procedimiento para insertar una empresa y asociar productos por defecto."
--🧠 Explicación: Este procedimiento inserta una empresa en companies, y luego vincula automáticamente productos predeterminados en companyproducts.

DELIMITER //

CREATE PROCEDURE insertar_empresa_y_asociar_productos (
    IN p_id VARCHAR(20),
    IN p_type_id INT,
    IN p_name VARCHAR(80),
    IN p_category_id INT,
    IN p_city_id INT,
    IN p_audience_id INT,
    IN p_cellphone VARCHAR(15),
    IN p_email VARCHAR(80)
)
BEGIN
    INSERT INTO companies (id, type_id, name, category_id, city_id, audience_id, cellphone, email)
    VALUES (p_id, p_type_id, p_name, p_category_id, p_city_id, p_audience_id, p_cellphone, p_email);

    INSERT INTO companyproducts (company_id, product_id, price, unitmeasure_id)
    VALUES 
        (p_id, 1, 10.00, 1),
        (p_id, 2, 15.00, 1),
        (p_id, 3, 20.00, 1);
END //

DELIMITER ;
