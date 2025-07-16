--🔎 1. Actualizar la fecha de modificación de un producto
--"Como desarrollador, deseo un trigger que actualice la fecha de modificación cuando se actualice un producto."
--🧠 Explicación: Cada vez que se actualiza un producto, queremos que el campo updated_at se actualice automáticamente con la fecha actual (NOW()), sin tener que hacerlo manualmente desde la app.
--🔁 Se usa un BEFORE UPDATE.
DELIMITER //
CREATE TRIGGER update_producto_modi
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;










