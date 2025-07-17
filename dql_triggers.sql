-- 1. Actualizar fecha de modificación de producto
DELIMITER //
CREATE TRIGGER trg_update_product_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;

-- 2. Registrar log al calificar producto
DELIMITER //
CREATE TRIGGER trg_log_product_rating
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (accion, tabla_afectada, id_registro, usuario_id, fecha)
    VALUES ('CALIFICACION', 'rates', NEW.id, NEW.customer_id, NOW());
END //
DELIMITER ;

-- 3. Validar unidad de medida en productos
DELIMITER //
CREATE TRIGGER trg_validate_product_unit
BEFORE INSERT ON companyproducts
FOR EACH ROW
BEGIN
    IF NEW.unitmeasure_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto debe tener una unidad de medida asignada';
    END IF;
END //
DELIMITER ;

-- 4. Validar calificaciones no mayores a 5
DELIMITER //
CREATE TRIGGER trg_validate_rating_value
BEFORE INSERT ON rates
FOR EACH ROW
BEGIN
    IF NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La calificación no puede ser mayor a 5';
    END IF;
END //
DELIMITER ;

-- 5. Actualizar estado de membresía cuando vence
DELIMITER //
CREATE TRIGGER trg_update_membership_status
BEFORE UPDATE ON customer_memberships
FOR EACH ROW
BEGIN
    IF NEW.end_date < CURDATE() THEN
        SET NEW.isactive = FALSE;
    END IF;
END //
DELIMITER ;

-- 6. Evitar duplicados de productos por empresa
DELIMITER //
CREATE TRIGGER trg_prevent_duplicate_products
BEFORE INSERT ON companyproducts
FOR EACH ROW
BEGIN
    DECLARE product_count INT;
    
    SELECT COUNT(*) INTO product_count
    FROM companyproducts
    WHERE company_id = NEW.company_id AND product_id = NEW.product_id;
    
    IF product_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este producto ya está registrado para esta empresa';
    END IF;
END //
DELIMITER ;

-- 7. Enviar notificación al añadir un favorito
DELIMITER //
CREATE TRIGGER trg_notify_favorite_added
AFTER INSERT ON details_favorites
FOR EACH ROW
BEGIN
    INSERT INTO notificaciones (usuario_id, mensaje, fecha)
    SELECT f.customer_id, CONCAT('Has añadido el producto ', p.name, ' a tus favoritos'), NOW()
    FROM favorites f
    JOIN products p ON NEW.product_id = p.id
    WHERE f.id = NEW.favorite_id;
END //
DELIMITER ;

-- 8. Insertar fila en quality_products tras calificación
DELIMITER //
CREATE TRIGGER trg_sync_quality_products
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
    VALUES (NEW.product_id, NEW.customer_id, NEW.poll_id, NEW.company_id, NEW.daterating, NEW.rating);
END //
DELIMITER ;

-- 9. Eliminar favoritos si se elimina el producto
DELIMITER //
CREATE TRIGGER trg_delete_orphaned_favorites
AFTER DELETE ON products
FOR EACH ROW
BEGIN
    DELETE FROM details_favorites WHERE product_id = OLD.id;
END //
DELIMITER ;

-- 10. Bloquear modificación de audiencias activas
DELIMITER //
CREATE TRIGGER trg_prevent_audience_update
BEFORE UPDATE ON audiences
FOR EACH ROW
BEGIN
    DECLARE audience_in_use INT;
    
    SELECT COUNT(*) INTO audience_in_use
    FROM customers
    WHERE audience_id = OLD.id;
    
    IF audience_in_use > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede modificar una audiencia en uso';
    END IF;
END //
DELIMITER ;

-- 11. Recalcular promedio de calidad del producto
DELIMITER //
CREATE TRIGGER trg_update_product_avg_rating
AFTER INSERT ON quality_products
FOR EACH ROW
BEGIN
    UPDATE products
    SET average_rating = (
        SELECT AVG(rating)
        FROM quality_products
        WHERE product_id = NEW.product_id
    )
    WHERE id = NEW.product_id;
END //
DELIMITER ;

-- 12. Registrar asignación de nuevo beneficio
DELIMITER //
CREATE TRIGGER trg_log_benefit_assignment
AFTER INSERT ON membershipbenefits
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, detalle, fecha)
    VALUES ('ASIGNACION_BENEFICIO', CONCAT('Beneficio ', NEW.benefit_id, ' asignado a membresía ', NEW.membership_id), NOW());
END //
DELIMITER ;

-- 13. Impedir doble calificación por cliente
DELIMITER //
CREATE TRIGGER trg_prevent_duplicate_rating
BEFORE INSERT ON rates
FOR EACH ROW
BEGIN
    DECLARE existing_rating INT;
    
    SELECT COUNT(*) INTO existing_rating
    FROM rates
    WHERE customer_id = NEW.customer_id AND product_id = NEW.product_id;
    
    IF existing_rating > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya has calificado este producto anteriormente';
    END IF;
END //
DELIMITER ;

-- 14. Validar correos duplicados en clientes
DELIMITER //
CREATE TRIGGER trg_validate_customer_email
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    DECLARE email_count INT;
    
    SELECT COUNT(*) INTO email_count
    FROM customers
    WHERE email = NEW.email;
    
    IF email_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo electrónico ya está registrado';
    END IF;
END //
DELIMITER ;

-- 15. Eliminar detalles de favoritos huérfanos
DELIMITER //
CREATE TRIGGER trg_delete_orphaned_favorite_details
AFTER DELETE ON favorites
FOR EACH ROW
BEGIN
    DELETE FROM details_favorites WHERE favorite_id = OLD.id;
END //
DELIMITER ;

-- 16. Actualizar campo updated_at en companies
DELIMITER //
CREATE TRIGGER trg_update_company_timestamp
BEFORE UPDATE ON companies
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;

-- 17. Impedir borrar ciudad con empresas activas
DELIMITER //
CREATE TRIGGER trg_prevent_city_deletion
BEFORE DELETE ON citiesormunicipalities
FOR EACH ROW
BEGIN
    DECLARE company_count INT;
    
    SELECT COUNT(*) INTO company_count
    FROM companies
    WHERE city_id = OLD.id;
    
    IF company_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar una ciudad con empresas registradas';
    END IF;
END //
DELIMITER ;

-- 18. Registrar cambios de estado en encuestas
DELIMITER //
CREATE TRIGGER trg_log_poll_status_change
AFTER UPDATE ON polls
FOR EACH ROW
BEGIN
    IF NEW.isactive <> OLD.isactive THEN
        INSERT INTO log_cambios_encuestas (poll_id, estado_anterior, estado_nuevo, fecha_cambio)
        VALUES (NEW.id, OLD.isactive, NEW.isactive, NOW());
    END IF;
END //
DELIMITER ;

-- 19. Sincronizar rates y quality_products
DELIMITER //
CREATE TRIGGER trg_sync_rates_quality
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM quality_products 
                  WHERE product_id = NEW.product_id 
                  AND customer_id = NEW.customer_id 
                  AND company_id = NEW.company_id) THEN
        INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
        VALUES (NEW.product_id, NEW.customer_id, NEW.poll_id, NEW.company_id, NEW.daterating, NEW.rating);
    END IF;
END //
DELIMITER ;

-- 20. Eliminar productos sin relación a empresas
DELIMITER //
CREATE TRIGGER trg_delete_orphaned_products
AFTER DELETE ON companyproducts
FOR EACH ROW
BEGIN
    DECLARE product_count INT;
    
    SELECT COUNT(*) INTO product_count
    FROM companyproducts
    WHERE product_id = OLD.product_id;
    
    IF product_count = 0 THEN
        DELETE FROM products WHERE id = OLD.product_id;
    END IF;
END //
DELIMITER ;