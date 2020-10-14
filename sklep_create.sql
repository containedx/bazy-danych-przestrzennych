-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-10-14 11:16:24.394

-- tables
-- Table: producenci
CREATE TABLE producenci (
    id_producenta int  NOT NULL,
    nazwa_producenta varchar(50)  NULL,
    mail varchar(30)  NULL,
    telefon varchar(10)  NOT NULL,
    CONSTRAINT producenci_pk PRIMARY KEY (id_producenta)
);

-- Table: produkty
CREATE TABLE produkty (
    id_produktu int  NOT NULL,
    nazwa_produktu varchar(50)  NULL,
    cena decimal(10,2)  NULL,
    id_producenta int  NULL,
    CONSTRAINT produkty_pk PRIMARY KEY (id_produktu)
);

-- Table: zamówienia
CREATE TABLE zamówienia (
    id_zamowienia int  NOT NULL,
    id_producenta int  NOT NULL,
    id_produktu int  NOT NULL,
    data date  NULL,
    ilosc int  NULL,
    suma decimal(10,2)  NOT NULL,
    CONSTRAINT zamówienia_pk PRIMARY KEY (id_zamowienia,id_producenta,id_produktu)
);

-- foreign keys
-- Reference: produkty_producenci (table: produkty)
ALTER TABLE produkty ADD CONSTRAINT produkty_producenci
    FOREIGN KEY (id_producenta)
    REFERENCES producenci (id_producenta)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: zamówienia_producenci (table: zamówienia)
ALTER TABLE zamówienia ADD CONSTRAINT zamówienia_producenci
    FOREIGN KEY (id_producenta)
    REFERENCES producenci (id_producenta)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: zamówienia_produkty (table: zamówienia)
ALTER TABLE zamówienia ADD CONSTRAINT zamówienia_produkty
    FOREIGN KEY (id_produktu)
    REFERENCES produkty (id_produktu)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

