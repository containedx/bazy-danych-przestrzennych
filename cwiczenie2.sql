-- zadanie 2,3,4,5

\c s301399
CREATE SCHEMA sklep;
SET search_path TO sklep;

-- wykonanie skryptu z pliku "sklep_create.sql"

-- zadanie 6
-- przykladowe inserty

INSERT INTO producenci VALUES (1, 'RESERVED', 'reserved@poczta.com', '666565476');

INSERT INTO produkty VALUES (1, 'dzinsy', 99.99, 1);

INSERT INTO zamówienia VALUES(1, 1, 1, '2020-01-12',  2, 199.98);	


-- zadanie 7,8,9,10

pg_dump -U postgres s301399 > backup.bak
dropdb -U postgres s301399
createdb -U postgres backup_s301399
psql -U postgres backup_s301399 < backup.bak
ALTER DATABASE backup_s301399 RENAME TO s301399


-- zadanie 11

SELECT 'Producent '||nazwa_producenta||', liczba zamowien: '||SUM(ilosc)||' wartosc zamowienia: '||SUM(suma) FROM producenci JOIN  zamówienia ON zamówienia.id_producenta = producenci.id_producenta GROUP BY producenci.id_producenta;
SELECT 'Produkt: '||nazwa_produktu||', liczba zamowien: '||SUM(ilosc) FROM produkty JOIN zamówienia ON zamówienia.id_produktu = produkty.id_produktu GROUP BY produkty.id_produktu;
SELECT * FROM zamówienia NATURAL JOIN produkty;
SELECT * FROM zamówienia WHERE DATE_PART('month', data) = 01;
SELECT SUM(suma) , DATE_PART('dow', data) FROM zamówienia GROUP BY DATE_PART('dow', data) ORDER BY SUM(suma) DESC;
SELECT id_produktu, SUM(id_produktu) FROM zamówienia GROUP BY id_produktu ORDER BY SUM(id_produktu) DESC;
   

-- zadanie 12

SELECT 'Produkt '||UPPER(nazwa_produktu)||' którego producentem jest '||LOWER(nazwa_producenta)||' zamówiono '||SUM(ilosc)||' razy' AS opis FROM produkty JOIN zamówienia ON zamówienia.id_produktu = produkty.id_produktu JOIN producenci ON zamówienia.id_producenta=producenci.id_producenta GROUP BY (nazwa_producenta, nazwa_produktu) ORDER BY SUM(ilosc) DESC;
SELECT * FROM zamówienia ORDER BY suma DESC LIMIT (SELECT COUNT(*) FROM zamówienia) - 3;

CREATE TABLE klienci(id_klienta INT PRIMARY KEY, email VARCHAR(50) NOT NULL, telefon VARCHAR(11) NOT NULL);
ALTER TABLE zamówienia ADD COLUMN id_klienta INT REFERENCES klienci(id_klienta);

-- przyklady uzupelniania danych:
INSERT INTO klienci VALUES(1, 'xyz@gmail.com', '443665776');
UPDATE zamówienia SET id_klienta = 1 WHERE id_zamowienia IN (1, 2, 5);

SELECT klienci.*, nazwa_produktu, ilosc, suma AS wartosc_zamówienia FROM klienci JOIN zamówienia ON klienci.id_klienta=zamówienia.id_klienta JOIN produkty ON zamówienia.id_produktu=produkty.id_produktu;

SELECT 'NAJCZĘŚCIEJ ZAMAWIAJĄCY: '||klienci.*,COUNT(id_zamowienia) FROM klienci JOIN zamówienia ON klienci.id_klienta=zamówienia.id_klienta GROUP BY(klienci) ORDER BY COUNT(id_zamowienia) DESC LIMIT 1;
SELECT 'NAJRZADZIEJ ZAMAWIAJĄCY: '||klienci.*,COUNT(id_zamowienia) FROM klienci JOIN zamówienia ON klienci.id_klienta=zamówienia.id_klienta GROUP BY(klienci) ORDER BY COUNT(id_zamowienia) LIMIT 1;

SELECT zamówienia.id_produktu FROM zamówienia JOIN produkty ON zamówienia.id_produktu = produkty.id_produktu GROUP BY zamówienia.id_produktu HAVING COUNT(id_zamowienia) = 0;
DELETE FROM produkty WHERE id_produktu IN ( SELECT zamówienia.id_produktu FROM zamówienia JOIN produkty ON zamówienia.id_produktu = produkty.id_produktu GROUP BY zamówienia.id_produktu HAVING COUNT(id_zamowienia) = 0 );


-- zadanie 13

CREATE TABLE numer( liczba INT );
CREATE SEQUENCE liczba_seq START WITH 100 INCREMENT BY 5 MINVALUE 0 MAXVALUE 125 CYCLE;
INSERT INTO numer VALUES(nextval('liczba_seq')); -- x7
ALTER SEQUENCE liczba_seq INCREMENT BY 6;
SELECT currval('liczba_seq');
SELECT nextval('liczba_seq');
DROP SEQUENCE liczba_seq;

-- zadanie 14

--uzytkownicy bazy:
\du 

CREATE USER Superuser301399 SUPERUSER;
CREATE USER guest301399;
GRANT USAGE ON SCHEMA sklep TO guest301399;
\du

ALTER USER Superuser301399 RENAME TO student;
ALTER USER student WITH NOSUPERUSER;
GRANT USAGE ON SCHEMA sklep TO student;
DROP OWNED BY guest301399;
DROP USER guest301399;

-- zadanie 15

START TRANSACTION;
UPDATE produkty SET cena = cena + 10.00;
COMMIT;

START TRANSACTION;
UPDATE produkty SET cena = 1.1*cena WHERE id_produktu = 3;
SAVEPOINT S1;
UPDATE zamówienia SET ilosc = 1.25*ilosc;
SAVEPOINT S2;
DELETE FROM zamówienia WHERE id_klienta IN (SELECT klienci.id_klienta  FROM klienci JOIN zamówienia ON klienci.id_klienta=zamówienia.id_klienta GROUP BY(klienci.id_klienta) ORDER BY COUNT(id_zamowienia) DESC LIMIT 1);
DELETE FROM klienci WHERE id_klienta IN (SELECT klienci.id_klienta  FROM klienci JOIN zamówienia ON klienci.id_klienta=zamówienia.id_klienta GROUP BY(klienci.id_klienta) ORDER BY COUNT(id_zamowienia) DESC LIMIT 1);
ROLLBACK TO S1;
ROLLBACK TO S2;
ROLLBACK;

CREATE OR REPLACE FUNCTION udzial()
RETURNS TABLE ( procent text ) AS
$$
BEGIN
	RETURN QUERY
	SELECT 'Procentowy udzial firmy '||nazwa_producenta||': '||(COUNT(id_zamowienia) / CAST((SELECT COUNT(*) FROM zamówienia) AS FLOAT))*100||'%' FROM  producenci JOIN zamówienia ON zamówienia.id_producenta=producenci.id_producenta GROUP BY nazwa_producenta;
END
$$ LANGUAGE plpgsql;





















