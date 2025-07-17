
-- Añadir columna para el promedio de calificación en productos
ALTER TABLE products ADD COLUMN average_rating DOUBLE(3,2) DEFAULT 0.00;

-- Añadir columna de pago confirmado para las membresías de clientes
ALTER TABLE customer_memberships ADD COLUMN pago_confirmado BOOLEAN DEFAULT FALSE;

-- Crear tabla para registrar errores de auditoría
CREATE TABLE IF NOT EXISTS errores_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_error VARCHAR(100),
    descripcion TEXT,
    id_referencia_1 VARCHAR(255),
    id_referencia_2 VARCHAR(255),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
)ENGINE=InnoDB;

-- Crear tabla para las preguntas de una encuesta
CREATE TABLE IF NOT EXISTS poll_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    poll_id INT,
    question_text TEXT,
    question_order INT,
    FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE
)ENGINE=InnoDB;

-- Crear tabla para el historial de cambios de precios
CREATE TABLE IF NOT EXISTS historial_precios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id VARCHAR(20),
    product_id INT,
    precio_anterior DOUBLE(10,2),
    precio_nuevo DOUBLE(10,2),
    fecha_cambio DATETIME,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
)ENGINE=InnoDB;

-- 1. Registrar calificación y actualizar el promedio del producto
-- "Como desarrollador, quiero un procedimiento que registre una calificación y actualice el promedio del producto."
-- 🔍 Explicación: Este procedimiento recibe product_id, customer_id y rating, inserta la nueva fila en quality_products, y recalcula automáticamente el promedio en la tabla products (campo average_rating).
DELIMITER //
CREATE PROCEDURE registrar_calificacion_y_actualizar_promedio(
    IN p_product_id INT,
    IN p_customer_id INT,
    IN p_company_id VARCHAR(20),
    IN p_poll_id INT,
    IN p_rating DOUBLE(10,2)
)
BEGIN
    DECLARE v_avg_rating DOUBLE(10,2);
    INSERT INTO quality_products(product_id, customer_id, poll_id, company_id, daterating, rating)
    VALUES (p_product_id, p_customer_id, p_poll_id, p_company_id, NOW(), p_rating);
    SELECT AVG(rating) INTO v_avg_rating
    FROM quality_products
    WHERE product_id = p_product_id;
    UPDATE products
    SET average_rating = v_avg_rating
    WHERE id = p_product_id;
END //
DELIMITER ;

-- 2. Insertar empresa y asociar productos por defecto
-- "Como administrador, deseo un procedimiento para insertar una empresa y asociar productos por defecto."
-- 🔍 Explicación: Este procedimiento inserta una empresa en companies, y luego vincula automáticamente productos predeterminados en companyproducts.
DELIMITER //
CREATE PROCEDURE insertar_empresa_con_productos_defecto(
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
    INSERT INTO companies(id, type_id, name, category_id, city_id, audience_id, cellphone, email)
    VALUES (p_id, p_type_id, p_name, p_category_id, p_city_id, p_audience_id, p_cellphone, p_email);
    INSERT INTO companyproducts (company_id, product_id, price, unitmeasure_id)
    SELECT p_id, p.id, p.price, 1
    FROM products p
    WHERE p.category_id = p_category_id
    LIMIT 2;
END //
DELIMITER ;

-- 3. Añadir producto favorito validando duplicados
-- "Como cliente, quiero un procedimiento que añada un producto favorito y verifique duplicados."
-- 🔍 Explicación: Verifica si el producto ya está en favoritos (details_favorites). Si no lo está, lo inserta. Evita duplicaciones silenciosamente.
DELIMITER //
CREATE PROCEDURE anadir_producto_favorito(
    IN p_customer_id INT,
    IN p_company_id VARCHAR(20),
    IN p_product_id INT
)
BEGIN
    DECLARE v_favorite_id INT;
    INSERT IGNORE INTO favorites(customer_id, company_id) VALUES (p_customer_id, p_company_id);
    SELECT id INTO v_favorite_id FROM favorites WHERE customer_id = p_customer_id AND company_id = p_company_id;
    INSERT IGNORE INTO details_favorites(favorite_id, product_id) VALUES (v_favorite_id, p_product_id);
END //
DELIMITER ;

-- 4. Generar resumen mensual de calificaciones por empresa
-- "Como gestor, deseo un procedimiento que genere un resumen mensual de calificaciones por empresa."
-- 🔍 Explicación: Hace una consulta agregada con AVG(rating) por empresa, y guarda los resultados en una tabla de resumen tipo resumen_calificaciones.
DELIMITER //
CREATE PROCEDURE generar_resumen_mensual_calificaciones(
    IN p_anio INT,
    IN p_mes INT
)
BEGIN
    DELETE FROM resumen_calificaciones WHERE año = p_anio AND mes = p_mes;
    INSERT INTO resumen_calificaciones (empresa_id, mes, año, promedio_calificacion, total_calificaciones, fecha_generacion)
    SELECT company_id, p_mes, p_anio, AVG(rating), COUNT(rating), NOW()
    FROM rates
    WHERE YEAR(daterating) = p_anio AND MONTH(daterating) = p_mes
    GROUP BY company_id;
END //
DELIMITER ;

-- 5. Calcular beneficios activos por membresía
-- "Como supervisor, quiero un procedimiento que calcule beneficios activos por membresía."
-- 🔍 Explicación: Consulta membershipbenefits junto con membershipperiods, y devuelve una lista de beneficios vigentes según la fecha actual.
DELIMITER //
CREATE PROCEDURE calcular_beneficios_activos_por_cliente(
    IN p_customer_id INT
)
BEGIN
    SELECT b.description, b.detail
    FROM customer_memberships cm
    JOIN membershipbenefits mb ON cm.membership_id = mb.membership_id
    JOIN benefits b ON mb.benefit_id = b.id
    WHERE 
        cm.customer_id = p_customer_id
        AND cm.isactive = TRUE
        AND cm.start_date <= CURDATE() 
        AND cm.end_date >= CURDATE();
END //
DELIMITER ;

-- 6. Eliminar productos huérfanos
-- "Como técnico, deseo un procedimiento que elimine productos sin calificación ni empresa asociada."
-- 🔍 Explicación: Elimina productos de la tabla products que no tienen relación ni en quality_products ni en companyproducts.
DELIMITER //
CREATE PROCEDURE eliminar_productos_huerfanos()
BEGIN
    DELETE p
    FROM products p
    LEFT JOIN companyproducts cp ON p.id = cp.product_id
    LEFT JOIN quality_products qp ON p.id = qp.product_id
    WHERE cp.product_id IS NULL AND qp.product_id IS NULL;
END //
DELIMITER ;

-- 7. Actualizar precios de productos por categoría
-- "Como operador, quiero un procedimiento que actualice precios de productos por categoría."
-- 🔍 Explicación: Recibe un categoria_id y un factor (por ejemplo 1.05), y multiplica todos los precios por ese factor en la tabla companyproducts.
DELIMITER //
CREATE PROCEDURE actualizar_precios_por_categoria(
    IN p_category_id INT,
    IN p_factor DOUBLE
)
BEGIN
    UPDATE companyproducts cp
    JOIN products p ON cp.product_id = p.id
    SET cp.price = cp.price * p_factor
    WHERE p.category_id = p_category_id;
END //
DELIMITER ;

-- 8. Validar inconsistencia entre rates y quality_products
-- "Como auditor, deseo un procedimiento que liste inconsistencias entre rates y quality_products."
-- 🔍 Explicación: Busca calificaciones (rates) que no tengan entrada correspondiente en quality_products. Inserta el error en una tabla errores_log.
DELIMITER //
CREATE PROCEDURE validar_inconsistencia_calificaciones()
BEGIN
    INSERT INTO errores_log (tipo_error, descripcion, id_referencia_1, id_referencia_2)
    SELECT 'INCONSISTENCIA_RATES_QUALITY', 'Registro en rates no tiene contraparte en quality_products', r.customer_id, r.company_id
    FROM rates r
    LEFT JOIN quality_products qp ON r.customer_id = qp.customer_id AND r.company_id = qp.company_id AND r.poll_id = qp.poll_id
    WHERE qp.product_id IS NULL;
END //
DELIMITER ;

-- 9. Asignar beneficios a nuevas audiencias
-- "Como desarrollador, quiero un procedimiento que asigne beneficios a nuevas audiencias."
-- 🔍 Explicación: Recibe un benefit_id y audience_id, verifica si ya existe el registro, y si no, lo inserta en audiencebenefits.
DELIMITER //
CREATE PROCEDURE asignar_beneficio_audiencia(
    IN p_audience_id INT,
    IN p_benefit_id INT
)
BEGIN
    INSERT IGNORE INTO audiencebenefits(audience_id, benefit_id)
    VALUES (p_audience_id, p_benefit_id);
END //
DELIMITER ;

-- 10. Activar planes de membresía vencidos con pago confirmado
-- "Como administrador, deseo un procedimiento que active planes de membresía vencidos si el pago fue confirmado."
-- 🔍 Explicación: Actualiza el campo isactive a TRUE en customer_memberships donde la fecha haya vencido pero el campo pago_confirmado sea TRUE.
DELIMITER //
CREATE PROCEDURE reactivar_membresias_pagadas()
BEGIN
    UPDATE customer_memberships
    SET 
        isactive = TRUE, end_date = DATE_ADD(end_date, INTERVAL 1 MONTH) 
    WHERE 
        end_date < CURDATE() AND isactive = FALSE AND pago_confirmado = TRUE;
END //
DELIMITER ;

-- 11. Listar productos favoritos del cliente con su calificación
-- "Como cliente, deseo un procedimiento que me devuelva todos mis productos favoritos con su promedio de rating."
-- 🔍 Explicación: Consulta todos los productos favoritos del cliente y muestra el promedio de calificación de cada uno, uniendo favorites, details_favorites y products.
DELIMITER //
CREATE PROCEDURE listar_favoritos_con_calificacion(
    IN p_customer_id INT
)
BEGIN
    SELECT p.name, p.detail, p.price, p.average_rating
    FROM favorites f
    JOIN details_favorites df ON f.id = df.favorite_id
    JOIN products p ON df.product_id = p.id
    WHERE f.customer_id = p_customer_id;
END //
DELIMITER ;

-- 13. Eliminar favoritos antiguos sin calificaciones
-- "Como técnico, deseo un procedimiento que borre favoritos antiguos no calificados en más de un año."
-- 🔍 Explicación: Filtra productos favoritos que no tienen calificaciones recientes y fueron añadidos hace más de 12 meses, y los elimina de details_favorites.
-- =================================================================
DELIMITER //
CREATE PROCEDURE eliminar_favoritos_antiguos_sin_calificacion()
BEGIN
    DELETE df
    FROM details_favorites df
    JOIN favorites f ON df.id = f.favorite_id
    JOIN historial_favorites hf ON f.customer_id = hf.customer_id AND f.company_id = hf.company_id
    LEFT JOIN quality_products qp ON df.product_id = qp.product_id AND f.customer_id = qp.customer_id
    WHERE
        hf.fecha_improve < DATE_SUB(NOW(), INTERVAL 1 YEAR) -- Añadido hace más de 1 año
        AND qp.product_id IS NULL; -- Nunca calificado por este cliente
END //
DELIMITER ;

-- =================================================================
-- 14. Asociar beneficios automáticamente por audiencia
-- "Como operador, quiero un procedimiento que asocie automáticamente beneficios por audiencia."
-- 🔍 Explicación: Inserta en audiencebenefits todos los beneficios que apliquen según una lógica predeterminada (por ejemplo, 'Envío gratis' para 'Empresas').
-- =================================================================
DELIMITER //
CREATE PROCEDURE asociar_beneficios_predeterminados_audiencia(
    IN p_audience_id INT,
    IN p_benefit_id INT
)
BEGIN
    -- Este procedimiento es idéntico en funcionalidad al #9
    -- Simplemente se reutiliza la lógica para una tarea específica
    INSERT IGNORE INTO audiencebenefits(audience_id, benefit_id)
    VALUES (p_audience_id, p_benefit_id);
END //
DELIMITER ;

-- =================================================================
-- 15. Historial de cambios de precio
-- "Como administrador, deseo un procedimiento para generar un historial de cambios de precio."
-- 🔍 Explicación: Cada vez que se cambia un precio, el procedimiento compara el anterior con el nuevo y guarda un registro en una tabla historial_precios.
-- =================================================================
DELIMITER //
CREATE PROCEDURE actualizar_precio_con_historial(
    IN p_company_id VARCHAR(20),
    IN p_product_id INT,
    IN p_nuevo_precio DOUBLE(10,2)
)
BEGIN
    DECLARE v_precio_anterior DOUBLE(10,2);

    -- Obtener el precio actual antes de la actualización
    SELECT price INTO v_precio_anterior 
    FROM companyproducts 
    WHERE company_id = p_company_id AND product_id = p_product_id;

    -- Si el precio ha cambiado, registrarlo y actualizarlo
    IF v_precio_anterior IS NOT NULL AND v_precio_anterior <> p_nuevo_precio THEN
        -- Registrar el cambio en el historial
        INSERT INTO historial_precios(company_id, product_id, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (p_company_id, p_product_id, v_precio_anterior, p_nuevo_precio, NOW());

        -- Actualizar el precio en la tabla principal
        UPDATE companyproducts
        SET price = p_nuevo_precio
        WHERE company_id = p_company_id AND product_id = p_product_id;
    END IF;
END //
DELIMITER ;

-- =================================================================
-- 16. Registrar encuesta activa automáticamente
-- "Como desarrollador, quiero un procedimiento que registre automáticamente una nueva encuesta activa."
-- 🔍 Explicación: Inserta una encuesta en polls con el campo isactive = TRUE y una fecha de inicio en NOW().
-- =================================================================
DELIMITER //
CREATE PROCEDURE registrar_encuesta_activa(
    IN p_name VARCHAR(80),
    IN p_description TEXT,
    IN p_categorypoll_id INT
)
BEGIN
    INSERT INTO polls (name, description, isactive, categorypoll_id)
    VALUES (p_name, p_description, TRUE, p_categorypoll_id);
END //
DELIMITER ;

-- =================================================================
-- 17. Actualizar unidad de medida de productos sin afectar ventas
-- "Como técnico, deseo un procedimiento que actualice la unidad de medida de productos sin afectar si hay ventas."
-- 🔍 Explicación: Verifica si el producto no ha sido vendido (no tiene calificaciones), y si es así, permite actualizar su unitmeasure_id.
-- =================================================================
DELIMITER //
CREATE PROCEDURE actualizar_unidad_medida_segura(
    IN p_company_id VARCHAR(20),
    IN p_product_id INT,
    IN p_nueva_unitmeasure_id INT
)
BEGIN
    DECLARE v_sales_count INT;

    -- Contar si el producto ha sido calificado (una aproximación a si fue vendido/usado)
    SELECT COUNT(*) INTO v_sales_count
    FROM quality_products
    WHERE product_id = p_product_id AND company_id = p_company_id;

    -- Si no hay registros de ventas/calificaciones, actualizar
    IF v_sales_count = 0 THEN
        UPDATE companyproducts
        SET unitmeasure_id = p_nueva_unitmeasure_id
        WHERE company_id = p_company_id AND product_id = p_product_id;
    END IF;
END //
DELIMITER ;

-- =================================================================
-- 18. Recalcular promedios de calidad semanalmente
-- "Como supervisor, quiero un procedimiento que recalcule todos los promedios de calidad cada semana."
-- 🔍 Explicación: Hace un AVG(rating) agrupado por producto y lo actualiza en products.
-- =================================================================
DELIMITER //
CREATE PROCEDURE recalcular_promedios_globales()
BEGIN
    UPDATE products p
    JOIN (
        SELECT product_id, AVG(rating) as avg_r
        FROM quality_products
        GROUP BY product_id
    ) qp ON p.id = qp