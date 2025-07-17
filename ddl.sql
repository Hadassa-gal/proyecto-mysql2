CREATE DATABASE IF NOT EXISTS proyecto;
USE proyecto;

CREATE TABLE countries (
    iscode VARCHAR(6) PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    alfaisotwo VARCHAR(2) UNIQUE,
    alfaisothree VARCHAR(4) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE subdivisioncategories (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(40) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE stateregions (
    code VARCHAR(6) PRIMARY KEY,
    name VARCHAR(60) UNIQUE,
    country_id VARCHAR(6),
    code3166 VARCHAR(10) UNIQUE,
    subdivision_id INT(11),
    FOREIGN KEY (country_id) REFERENCES countries(iscode),
    FOREIGN KEY (subdivision_id) REFERENCES subdivisioncategories(id)
)ENGINE=InnoDB;

CREATE TABLE citiesormunicipalities (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(60),
    statereg_id VARCHAR(6),
    FOREIGN KEY (statereg_id) REFERENCES stateregions(code)
)ENGINE=InnoDB;

CREATE TABLE typesofidentifications (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(60),
    suffix VARCHAR(5) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE unitofmeasure (
    id INT(11) PRIMARY KEY,
    description VARCHAR(60) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE categories (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(60) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE audiences (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(60) 
)ENGINE=InnoDB;

CREATE TABLE companies (
    id VARCHAR(20) PRIMARY KEY,
    type_id INT(11),
    name VARCHAR(80),
    category_id INT(11),
    city_id INT(11),
    audience_id INT(11),
    cellphone VARCHAR(15),
    email VARCHAR(80),
    FOREIGN KEY (type_id) REFERENCES typesofidentifications(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (city_id) REFERENCES citiesormunicipalities(id),
    FOREIGN KEY (audience_id) REFERENCES audiences(id)
)ENGINE=InnoDB;

CREATE TABLE customers (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80),
    city_id INT(11),
    audience_id INT(11),
    cellphone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(120),
    FOREIGN KEY (city_id) REFERENCES citiesormunicipalities(id),
    FOREIGN KEY (audience_id) REFERENCES audiences(id)
)ENGINE=InnoDB;

CREATE TABLE products (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(60),
    detail TEXT,
    price DOUBLE(10,2),
    category_id INT(11),
    image VARCHAR(80),
    FOREIGN KEY (category_id) REFERENCES categories(id)
)ENGINE=InnoDB;

CREATE TABLE companyproducts (
    company_id VARCHAR(20),
    product_id INT(11),
    price DOUBLE(10,2),
    unitmeasure_id INT(11),
    PRIMARY KEY (company_id, product_id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (unitmeasure_id) REFERENCES unitofmeasure(id)
)ENGINE=InnoDB;

CREATE TABLE favorites (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    customer_id INT(11),
    company_id VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
)ENGINE=InnoDB;

CREATE TABLE details_favorites (
    id INT(11) PRIMARY KEY,
    favorite_id INT(11),
    product_id INT(11),
    FOREIGN KEY (favorite_id) REFERENCES favorites(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
)ENGINE=InnoDB;

CREATE TABLE polls (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) UNIQUE,
    description TEXT,
    isactive BOOLEAN,
    categorypoll_id INT(11),
    FOREIGN KEY (categorypoll_id) REFERENCES categories(id)
)ENGINE=InnoDB;

CREATE TABLE quality_products (
    product_id INT(11),
    customer_id INT(11),
    poll_id INT(11),
    company_id VARCHAR(20),
    daterating DATETIME,
    rating DOUBLE(10,2),
    PRIMARY KEY (product_id, customer_id, poll_id, company_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (poll_id) REFERENCES polls(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
)ENGINE=InnoDB;

CREATE TABLE memberships (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE,
    description TEXT
)ENGINE=InnoDB;

CREATE TABLE periods (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE membershipperiods (
    membership_id INT(11),
    period_id INT(11),
    price DOUBLE(10,2),
    PRIMARY KEY (membership_id, period_id),
    FOREIGN KEY (membership_id) REFERENCES memberships(id),
    FOREIGN KEY (period_id) REFERENCES periods(id)
)ENGINE=InnoDB;

CREATE TABLE benefits (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(80),
    detail TEXT
)ENGINE=InnoDB;

CREATE TABLE membershipbenefits (
    membership_id INT(11),
    period_id INT(11),
    audience_id INT(11),
    benefit_id INT(11),
    PRIMARY KEY (membership_id, period_id, audience_id, benefit_id),
    FOREIGN KEY (membership_id) REFERENCES memberships(id),
    FOREIGN KEY (period_id) REFERENCES periods(id),
    FOREIGN KEY (audience_id) REFERENCES audiences(id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(id)
)ENGINE=InnoDB;

CREATE TABLE audiencebenefits (
    audience_id INT(11),
    benefit_id INT(11),
    PRIMARY KEY (audience_id, benefit_id),
    FOREIGN KEY (audience_id) REFERENCES audiences(id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(id)
)ENGINE=InnoDB;

CREATE TABLE categories_polls (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) UNIQUE
)ENGINE=InnoDB;

CREATE TABLE rates (
    customer_id INT(11),
    company_id VARCHAR(20),
    poll_id INT(11),
    daterating DATETIME,
    rating DOUBLE(10,2),
    PRIMARY KEY (customer_id, company_id, poll_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (poll_id) REFERENCES polls(id)
)ENGINE=InnoDB;

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

ALTER TABLE products 
ADD COLUMN updated_at DATETIME;

DROP TABLE IF EXISTS historial_favorites;

CREATE TABLE historial_favorites (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    favorite_id INT(11),
    accion VARCHAR(20), -- 'añadir' o 'eliminar'
    fecha_improve TIMESTAMP,
    FOREIGN KEY (favorite_id) REFERENCES favorites(id)
) ENGINE=InnoDB;