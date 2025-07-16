--🔹 1. Borrar productos sin actividad cada 6 meses

 --   Historia: Como administrador, quiero un evento que borre productos sin actividad cada 6 meses.

--🧠 Explicación: Algunos productos pueden haber sido creados pero nunca calificados, marcados como favoritos ni asociados a una empresa. Este evento eliminaría esos productos cada 6 meses.

--🛠️ Se usaría un DELETE sobre products donde no existan registros en rates, favorites ni companyproducts.

--📅 Frecuencia del evento: EVERY 6 MONTH

DELIMITER //
    CREATE EVENT IF NOT EXISTS Borrar_productos_6meses
    ON SCHEDULE EVERY 6 MONTH
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
    ON COMPLETION PRESERVE
    DO
    BEGIN
        DELETE FROM products
        WHERE id NOT IN (SELECT DISTINCT product_id FROM rates)
        AND id NOT IN (SELECT DISTINCT product_id FROM quality_products)
        AND id NOT IN (SELECT DISTINCT product_id FROM details_favorites)
        AND id NOT IN (SELECT DISTINCT product_id FROM companyproducts);
    END //
  
  DELIMITER ;