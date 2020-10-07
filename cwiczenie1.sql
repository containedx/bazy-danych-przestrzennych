CREATE DATABASE s301399;
CREATE SCHEMA firma; 
CREATE ROLE ksiegowosc;
GRANT USAGE ON SCHEMA firma TO ksiegowosc;

CREATE TABLE firma.pracownicy( id_pracownika INT NOT NULL, imie TEXT, nazwisko TEXT, adres TEXT, telefon TEXT);

CREATE TABLE firma.godziny( id_godziny INT NOT NULL, data DATE, liczba_godzin INT, id_pracownika INT NOT NULL);

CREATE TABLE firma.pensja_stanowisko( id_pensji INT NOT NULL, stanowisko TEXT, kwota FLOAT);

CREATE TABLE firma.premia( id_premii INT NOT NULL, rodzaj TEXT, kwota FLOAT); 

CREATE TABLE firma.wynagrodzenie( id_wynagrodzenia INT NOT NULL, data DATE, id_pracownika INT NOT NULL, id_godziny INT NOT NULL, id_pensji INT NOT NULL, id_premii INT NOT NULL);

ALTER TABLE firma.pracownicy ADD PRIMARY KEY(id_pracownika);
ALTER TABLE firma.godziny ADD PRIMARY KEY(id_godziny);
ALTER TABLE firma.pensja_stanowisko ADD PRIMARY KEY(id_pensji);
ALTER TABLE firma.premia ADD PRIMARY KEY(id_premii);
ALTER TABLE firma.wynagrodzenie ADD PRIMARY KEY(id_wynagrodzenia);

ALTER TABLE firma.godziny ADD FOREIGN KEY(id_pracownika) REFERENCES firma.pracownicy(id_pracownika);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY(id_pracownika) REFERENCES firma.pracownicy(id_pracownika);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY(id_godziny) REFERENCES firma.godziny(id_godziny);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY(id_pensji) REFERENCES firma.pensja_stanowisko(id_pensji);
ALTER TABLE firma.wynagrodzenie ADD FOREIGN KEY(id_premii) REFERENCES firma.premia(id_premii);

--------------- przykladowe inserty:
INSERT INTO firma.pracownicy VALUES ( 1, 'Jan', 'Kowalski', 'ul.Kwiatowa16', '453453453');
INSERT INTO firma.godziny VALUES( 1, '2000-01-01', 100, 1);
INSERT INTO firma.pensja_stanowisko VALUES(1, 'informatyk', 15000);
INSERT INTO firma.premia VALUES(1, 'rodzaj premii', 200000);
INSERT INTO firma.wynagrodzenie VALUES(1, '2000-01-01', 1, 1, 1, 1);

ALTER TABLE firma.wynagrodzenie ALTER COLUMN data SET DATA TYPE TEXT;

----------------zadanie 6
SELECT id_pracownika, nazwisko FROM firma.pracownicy;
SELECT id_pracownika FROM firma.wynagrodzenie WHERE id_pensji = ( SELECT id_pensji FROM firma.pensja_stanowisko WHERE kwota>1000 ) ;
SELECT id_pracownika FROM firma.wynagrodzenie WHERE id_pensji = ( SELECT id_pensji FROM firma.pensja_stanowisko WHERE kwota>2000  AND id_premii = NULL) ;
SELECT id_pracownika FROM firma.pracownicy WHERE imie LIKE 'J%';
SELECT id_pracownika FROM firma.pracownicy WHERE imie LIKE '%a' AND nazwisko LIKE '%n%';
SELECT firma.pracownicy.imie, firma.pracownicy.nazwisko, firma.godziny.liczba_godzin FROM firma.pracownicy, firma.godziny WHERE firma.pracownicy.id_pracownika = firma.godziny.id_godziny;
SELECT imie, nazwisko FROM firma.pracownicy WHERE id_pracownika = (SELECT id_pracownika FROM firma.wynagrodzenie WHERE id_pensji = ( SELECT id_pensji FROM firma.pensja_stanowisko WHERE kwota>1500 AND kwota<3000 )) ;


----------------zadanie 7
SELECT imie, nazwisko FROM firma.pracownicy JOIN firma.wynagrodzenie ON firma.pracownicy.id_pracownika=firma.wynagrodzenie.id_pracownika JOIN firma.pensja_stanowisko ON firma.wynagrodzenie.id_pensji=firma.pensja_stanowisko.id_pensji ORDER BY firma.pensja_stanowisko.kwota;
SELECT imie, nazwisko FROM firma.pracownicy JOIN firma.wynagrodzenie ON firma.pracownicy.id_pracownika=firma.wynagrodzenie.id_pracownika JOIN firma.pensja_stanowisko ON firma.wynagrodzenie.id_pensji=firma.pensja_stanowisko.id_pensji JOIN firma.premia ON firma.premia.id_premii = firma.wynagrodzenie.id_premii ORDER BY firma.pensja_stanowisko.kwota DESC, firma.premia.kwota;
SELECT stanowisko, COUNT(stanowisko) FROM firma.pensja_stanowisko GROUP BY stanowisko;
SELECT AVG(kwota) FROM firma.pensja_stanowisko WHERE stanowisko='informatyk';
SELECT MAX(kwota) FROM firma.pensja_stanowisko WHERE stanowisko='informatyk';
SELECT MIN(kwota) FROM firma.pensja_stanowisko WHERE stanowisko='informatyk';
SELECT SUM(kwota) FROM firma.pensja_stanowisko;
SELECT stanowisko, SUM(kwota) FROM firma.pensja_stanowisko GROUP BY stanowisko;
SELECT stanowisko, COUNT(firma.wynagrodzenie.id_premii) FROM firma.wynagrodzenie JOIN firma.pensja_stanowisko ON firma.pensja_stanowisko.id_pensji=firma.pensja_stanowisko.id_pensji GROUP BY stanowisko;

//DELETE FROM firma.pracownicy JOIN firma.wynagrodzenie ON firma.wynagrodzenie.id_pracownika=firma.pracownicy.id_pracownika JOIN firma.pensja_stanowisko ON firma.stanowisko.id_pensji=firma.wynagrodzenie.id_pensji WHERE kwota<1200;

----------------zadanie 8
SELECT '+48' || telefon FROM firma.pracownicy;
SELECT UPPER(imie), UPPER(nazwisko) FROM firma.pracownicy ORDER BY LENGTH(nazwisko) DESC LIMIT 1 ;
SELECT MD5(imie||nazwisko||adres||telefon||pensja_stanowisko.kwota) FROM firma.pracownicy JOIN firma.wynagrodzenie ON firma.pracownicy.id_pracownika=firma.wynagrodzenie.id_pracownika  JOIN firma.pensja_stanowisko ON firma.pensja_stanowisko.id_pensji=firma.pensja_stanowisko.id_pensji;

----------------zadanie 9 - RAPORT 
SELECT 'Pracownik '||imie||' '||nazwisko||' w dniu '||data||' otrzymal pensje calkowita na kwote '||firma.pensja_stanowisko.kwota||' gdzie wynagrodzenie to '||firma.stanowisko_pensja.kwota-firma.premia.kwota||' premia: '||firma.premia.kwota RAPORT FROM firma.pracownicy JOIN firma.wynagrodzenie ON firma.pracownicy.id_pracownika=firma.wynagrodzenie.id_pracownika  JOIN firma.pensja_stanowisko ON firma.pensja_stanowisko.id_pensji=firma.pensja_stanowisko.id_pensji JOIN firma.premia ON firma.premia.id_premii = firma.wynagrodzenie.id_premii;










