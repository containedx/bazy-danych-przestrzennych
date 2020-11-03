-- zadanie 1

CREATE TABLE obiekty ( id SERIAL PRIMARY KEY, nazwa VARCHAR(50), geom GEOMETRY);


-- a

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt1', ST_GeomFromEWKT('SRID=0; GEOMETRYCOLLECTION( LINESTRING(0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1, 4 2, 5 1), LINESTRING(5 1, 6 1))'));


-- b

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt2', ST_GeomFromEWKT('SRID=0; GEOMETRYCOLLECTION(CIRCULARSTRING(14 6, 16 4, 14 2, 12 0, 10 2, 10 6, 14 6),CIRCULARSTRING(11 2, 13 2, 11 2))'));


-- c

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt3', ST_GeomFromEWKT('SRID=0; TRIANGLE((10 17, 12 13, 7 15,10 17))'));


-- d 

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt4', ST_GeomFromEWKT('SRID=0; LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'));


-- e 

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt5', ST_GeomFromEWKT('SRID=0; GEOMETRYCOLLECTION( POINTM(30 30 59), POINTM(38 32 234))'));


-- f 

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt6', ST_GeomFromEWKT('SRID=0; GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))'));



-- zadanie 2

SELECT ST_Area(ST_Buffer(ST_ShortestLine((SELECT geom FROM obiekty WHERE nazwa='obiekt3'),(SELECT geom FROM obiekty WHERE nazwa='obiekt4')),5));


-- zadanie 3

-- nie mozna zrobic poligonu poniewaz obiekt nie jest zamknięty. Trzeba go domknąć by spełnił te warunki. 

UPDATE obiekty SET  geom = ST_MakePolygon(ST_MakeLine((SELECT geom FROM obiekty WHERE nazwa = 'obiekt4'),ST_GeomFromEWKT('SRID=0; LINESTRING(20.5 19.5, 20 20)'))) WHERE nazwa = 'obiekt4';



-- zadanie 4

INSERT INTO obiekty(nazwa, geom) VALUES('obiekt7', ST_Union((SELECT geom FROM obiekty WHERE nazwa = 'obiekt3'), (SELECT geom FROM obiekty WHERE nazwa = 'obiekt4' )));


- zadanie 5

SELECT SUM(ST_Area(ST_Buffer(geom,5))) FROM obiekty WHERE NOT ST_HASARC(geom);