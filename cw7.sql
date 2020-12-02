-- cwiczenia 7 

-- nowa baza danych 

CREATE DATABASE rasters_database;
\c rasters_database
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
pg_restore -U postgres -d rasters_database postgis_raster.backup

-- struktura bazy danych 

ALTER SCHEMA schema_name RENAME TO zawarty;

-- ładowanie danych rastrowych

"C:\Program Files\PostgreSQL\13\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d .\srtm_1arc_v3.tif rasters.dem > dem.sql

"C:\Program Files\PostgreSQL\13\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d .\srtm_1arc_v3.tif rasters.dem | psql -d raster -h localhost -U postgres -p 5432

"C:\Program Files\PostgreSQL\13\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 128x128 -I -C -M -d .\Landsat8_L1TP_RGBN.TIF rasters.landsat8 | psql -d raster -h localhost -U postgres -p 5432


-- tworzenie rastrów z istniejących rastrów i interakcja z wektorami

CREATE TABLE zawarty.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND lower(b.municipality) like 'porto';

ALTER TABLE zawarty.intersects ADD COLUMN rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON zawarty.intersects USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zawarty'::name, 'intersects'::name,'rast'::name);

CREATE TABLE zawarty.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND lower(b.municipality) like 'porto';

CREATE TABLE zawarty.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.municipality) like 'porto' and ST_Intersects(b.geom,a.rast);



-- RASTROWANIE - tworzenie rastrów z wektorów 

CREATE TABLE zawarty.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE lower(a.municipality) like 'porto';

DROP TABLE zawarty.porto_parishes; --> drop table porto_parishes first
CREATE TABLE zawarty.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE lower(a.municipality) like 'porto';


-- WEKTORYZOWANIE -  konwertowanie rastrów na wektory  

CREATE TABLE zawarty.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.parish) like 'paranhos' and ST_Intersects(b.geom,a.rast);

CREATE TABLE zawarty.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.parish) like 'paranhos' and ST_Intersects(b.geom,a.rast);



-- ANALIZA RASTRÓW

CREATE TABLE zawarty.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.dem;

CREATE TABLE zawarty.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.parish) like 'paranhos' and ST_Intersects(b.geom,a.rast);

CREATE TABLE zawarty.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM zawarty.paranhos_dem AS a;

CREATE TABLE zawarty.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM zawarty.paranhos_slope AS a;

SELECT st_summarystats(a.rast) AS stats
FROM zawarty.paranhos_dem AS a;

SELECT st_summarystats(ST_Union(a.rast))
FROM zawarty.paranhos_dem AS a;

WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM zawarty.paranhos_dem AS a )
SELECT (stats).min,(stats).max,(stats).mean FROM t;

WITH t AS 
( SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.municipality) like 'porto' and
ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;


-- TOPOGRAPHIC POSITION INDEX

create table zawarty.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON zawarty.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zawarty'::name,'tpi30'::name,'rast'::name);

-- TPI dla gminy Porto

CREATE TABLE zawarty.tpiPorto AS
SELECT ST_TPI(raster.rast, 1)
FROM rasters.dem AS raster, vectors.porto_parishes AS vector
WHERE ST_Intersects(raster.rast, vector.geom) AND vector.municipality = 'PORTO';

CREATE INDEX idx_tpiporto_rast_gist ON zawarty.tpiPorto
USING gist (ST_ConvexHull(st_tpi));

SELECT AddRasterConstraints('zawarty'::name, 'tpiporto'::name,'st_tpi'::name);




-- ALGEBRA MAP

CREATE TABLE zawarty.porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.municipality) like 'porto' and
ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra( r.rast, 1, r.rast, 4,
		    '([rast2.val] - [rast1.val]) / ([rast2.val] +[rast1.val])::float',
		    '32BF') AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON zawarty.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zawarty'::name,'porto_ndvi'::name,'rast'::name); 

-- funckja zwrotna

create or replace function zawarty.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;


CREATE TABLE zawarty.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE lower(b.municipality) like 'porto' and
ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'zawarty.ndvi(double precision[],
integer[],text[])'::regprocedure,
'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON zawarty.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zawarty'::name,'porto_ndvi2'::name,'rast'::name);


-- funkcje TPI :
-- public._st_tpi4ma
-- public.st_tpi


-- EKSPORT DANYCH

SELECT ST_AsTiff(ST_Union(rast)) FROM zawarty.porto_ndvi;

SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE','PREDICTOR=2', 'PZLEVEL=9'])
FROM zawarty.porto_ndvi;

-- lista dostępnych formatow gdal
SELECT ST_GDALDrivers();

-- na dysku

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM zawarty.porto_ndvi;

SELECT lo_export(loid, 'C:\myraster.tiff')
 FROM tmp_out;

SELECT lo_unlink(loid)
 FROM tmp_out;                --> Delete the large object.











