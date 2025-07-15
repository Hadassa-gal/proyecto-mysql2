# **Proyecto de mysql 2**



## **1. Cambios de las tablas**

Se añadieron 4 tablas a la base de datos

![](https://i.ibb.co/JwMnYkcr/DERPlat-Products.png)

```sql

CREATE TABLE customer_memberships (
    customer_id INT(11),
    membership_id INT(11),
    start_date DATE,
    end_date DATE,
    isactive BOOLEAN,
    PRIMARY KEY (customer_id, membership_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (membership_id) REFERENCES memberships(id)
)ENGINE=InnoDB;

CREATE TABLE resumen_calificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id VARCHAR(20),
    mes INT,
    año INT,
    promedio_calificacion DOUBLE(10,2),
    total_calificaciones INT,
    fecha_generacion DATETIME,
    FOREIGN KEY (empresa_id) REFERENCES companies(id)
)ENGINE=InnoDB;

CREATE TABLE historial_favorites (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    customer_id INT(11),
    company_id VARCHAR(20),
    fecha_improve TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES favorites(customer_id),
    FOREIGN KEY (company_id) REFERENCES favorites(company_id)
)ENGINE=InnoDB;

CREATE TABLE historial_rates (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    customer_id INT(11),
    company_id VARCHAR(20),
    poll_id INT(11),
    daterating DATETIME,
    rating DOUBLE(10,2),
    FOREIGN KEY (customer_id) REFERENCES rates(customer_id),
    FOREIGN KEY (company_id) REFERENCES rates(company_id),
    FOREIGN KEY (poll_id) REFERENCES rates(poll_id),
    FOREIGN KEY (daterating) REFERENCES rates(daterating),
    FOREIGN KEY (rating) REFERENCES rates(rating)
)ENGINE=InnoDB;
```

