-- zadanie 4

SELECT popp.* FROM popp, majrivers WHERE popp.f_codedesc LIKE 'Building' GROUP BY popp.gid HAVING MIN(ST_Distance(majrivers.geom, popp.geom)) < 100000;


CREATE TABLE tableB AS SELECT popp.* FROM popp, majrivers WHERE popp.f_codedesc LIKE 'Building' GROUP BY popp.gid HAVING MIN(ST_Distance(majrivers.geom, popp.geom)) < 100000;

SELECT COUNT(gid) FROM tableB;


-- zadanie 5

CREATE TABLE airportsNew(gid SERIAL, name VARCHAR(30), geom GEOMETRY, elev NUMERIC);
INSERT INTO airportsNew( name, geom, elev) SELECT name, geom, elev FROM airports;

SELECT airportsNew.*, ST_Y(geom) AS y FROM airportsNew ORDER BY y DESC LIMIT 1;
SELECT airportsNew.*, ST_Y(geom) AS y FROM airportsNew ORDER BY y LIMIT 1;

INSERT INTO airportsNew(name, geom, elev) VALUES
('airportB', 
CONCAT('Point(',(SELECT((SELECT ST_Y(geom) FROM airportsNew ORDER BY ST_Y(geom) DESC LIMIT 1) + (SELECT ST_Y(geom) FROM airportsNew ORDER BY ST_Y(geom) LIMIT 1))/2),' ', (SELECT((SELECT ST_X(geom) AS x FROM airportsNew ORDER BY x DESC LIMIT 1) + (SELECT ST_X(geom) AS x FROM airportsNew ORDER BY x LIMIT 1))/2),')'),
0);



-- zadanie 6

SELECT ST_Area(ST_Buffer(ST_ShortestLine((SELECT geom FROM lakes WHERE names LIKE 'Iliamna Lake'),(SELECT geom FROM airports WHERE name LIKE 'AMBLER')), 1000));


-- zadanie 7

SELECT vegdesc, SUM(area_km2) FROM (SELECT vegdesc, trees.area_km2 FROM trees JOIN tundra ON trees.geom = tundra.geom)  AS tundra_trees GROUP BY vegdesc;
SELECT vegdesc, SUM(area_km2) FROM (SELECT vegdesc, trees.area_km2 FROM trees JOIN swamp ON trees.geom = swamp.geom) AS swamp_trees GROUP BY vegdesc;






