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

--3. Añadir producto favorito validando duplicados
--"Como cliente, quiero un procedimiento que añada un producto favorito y verifique duplicados."
--🧠 Explicación: Verifica si el producto ya está en favoritos (details_favorites). Si no lo está, lo inserta. Evita duplicaciones silenciosamente.
DELIMITER //
CREATE PROCEDURE agregar_producto_favorito(
    IN p_favorite_id INT,
    IN p_product_id INT
)
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*) INTO contador
    FROM details_favorites
    WHERE favorite_id = p_favorite_id AND product_id = p_product_id;
    IF contador = 0 THEN
        INSERT INTO details_favorites (id, favorite_id, product_id)
        VALUES (NULL, p_favorite_id, p_product_id);
    END IF;
END //
DELIMITER ;

--4. Generar resumen mensual de calificaciones por empresa
--"Como gestor, deseo un procedimiento que genere un resumen mensual de calificaciones por empresa."
--🧠 Explicación: Hace una consulta agregada con AVG(rating) por empresa, y guarda los resultados en una tabla de resumen tipo resumen_calificaciones.
DELIMITER //
CREATE PROCEDURE generar_resumen_calificaciones()
BEGIN
    INSERT INTO resumen_calificaciones (
        empresa_id, mes, año, promedio_calificacion, total_calificaciones, fecha_generacion
    )
    SELECT
        company_id,
        MONTH(NOW()), YEAR(NOW()),
        ROUND(AVG(rating), 2),
        COUNT(*),
        NOW()
    FROM quality_products
    WHERE YEAR(daterating) = YEAR(NOW()) AND MONTH(daterating) = MONTH(NOW())
    GROUP BY company_id;
END //
DELIMITER ;

--5. Calcular beneficios activos por membresía
--"Como supervisor, quiero un procedimiento que calcule beneficios activos por membresía."
--🧠 Explicación: Consulta membershipbenefits junto con membershipperiods, y devuelve una lista de beneficios vigentes según la fecha actual.
DELIMITER //
CREATE PROCEDURE beneficios_activos_por_membresia(IN p_fecha DATE)
BEGIN
    SELECT
        mb.membership_id,
        m.name AS nombre_membresia,
        b.description AS beneficio,
        b.detail,
        a.description AS audiencia,
        mp.period_id,
        p.name AS periodo,
        mp.price
    FROM membershipbenefits mb
    JOIN memberships m ON m.id = mb.membership_id
    JOIN periods p ON p.id = mb.period_id
    JOIN benefits b ON b.id = mb.benefit_id
    JOIN audiences a ON a.id = mb.audience_id
    JOIN membershipperiods mp ON mp.membership_id = mb.membership_id AND mp.period_id = mb.period_id
    WHERE EXISTS (
        SELECT 1 FROM customer_memberships cm
        WHERE cm.membership_id = mb.membership_id
          AND cm.start_date <= p_fecha
          AND cm.end_date >= p_fecha
          AND cm.isactive = TRUE
    );
END //
DELIMITER ;

