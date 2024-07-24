USE JobSimDB;

/* 3.1
pokaza� firmy z wojew�dztwa (wybra�)
w kt�rych nigdy nie pracowa�y osoby z miasta o nazwie
(wybrac nazw�)
*/
DECLARE @MIAST nvarchar(20);
SET @MIAST = N'Dobre';
DECLARE @WOJ nvarchar(10);
SET @WOJ = N'MAZ';

/* usuniecie z listy wszystkich firm z wojewodztwa woj
	listy firm w ktorych kiedys pracowaly osoby z danego miasta */
SELECT FIRMY.nazwa as wybrane_firmy
FROM FIRMY 
FULL OUTER JOIN (SELECT DISTINCT FIRMY.nazwa 
					FROM FIRMY
					JOIN MIASTA miasto_firmy ON miasto_firmy.id_miasta = FIRMY.id_miasta
					JOIN WOJ ON WOJ.kod_woj = miasto_firmy.kod_woj
					JOIN ETATY ON ETATY.id_firmy = FIRMY.nazwa_skr
					JOIN OSOBY ON OSOBY.id_osoby = ETATY.id_osoby
					JOIN MIASTA miasto_osoby ON OSOBY.id_miasta = miasto_osoby.id_miasta
					WHERE miasto_osoby.nazwa = @MIAST /* pracowaly osoby z miasta miast */
					AND WOJ.kod_woj = @WOJ /* firma z wojewodztwa woj */) AS pozostale_firmy
ON pozostale_firmy.nazwa = FIRMY.nazwa
JOIN MIASTA ON MIASTA.id_miasta = FIRMY.id_miasta
JOIN WOJ ON WOJ.kod_woj = MIASTA.kod_woj
WHERE WOJ.kod_woj = @WOJ 
AND pozostale_firmy.nazwa is NULL;


/* 3.2 
Z3.2
Pokaza� osoby kt�re nigdy nie mia�y etatu na stanowisku (wybra� jakie� lub 2)
w firmach z wojew�dztw (wybra� ze 2 nazwy)

Uzasadni� wynik, �e faktycznie w tych WOJ s� firmy
i faktycznie te osoby niepracowa�y nigdy w nich 
*/
DECLARE @STAN nvarchar(20);
SET @WOJ = N'WIE';
SET @STAN = N'kozak';

/* wybranie osob ktore spelniaja przeciwne warunki
	i wybranie reszty osob */
SELECT OSOBY.id_osoby as id_wybranych_osob
FROM (SELECT DISTINCT OSOBY.id_osoby 
		FROM OSOBY
		JOIN ETATY on OSOBY.id_osoby = ETATY.id_osoby
		JOIN FIRMY on FIRMY.nazwa_skr = ETATY.id_firmy
		JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
		JOIN WOJ on MIASTA.kod_woj = WOJ.kod_woj
		WHERE WOJ.kod_woj = @WOJ
		AND ETATY.stanowisko = @STAN) AS pozostale_osoby
FULL OUTER JOIN OSOBY on OSOBY.id_osoby = pozostale_osoby.id_osoby
WHERE pozostale_osoby.id_osoby is NULL; 

/* pozostale osoby pracujace w firmach z woj na stanowisku stan, 
   przeciecie osob wybranych i pozostalych puste, wiec zapytanie poprawne */
SELECT DISTINCT OSOBY.id_osoby as id_pozostalych_osob
FROM OSOBY
JOIN ETATY on OSOBY.id_osoby = ETATY.id_osoby
JOIN FIRMY on FIRMY.nazwa_skr = ETATY.id_firmy
JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
JOIN WOJ on MIASTA.kod_woj = WOJ.kod_woj
WHERE WOJ.kod_woj = @WOJ
AND ETATY.stanowisko = @STAN;

/* firmy z danego wojewodztwa istnieja */
SELECT FIRMY.nazwa as firmy_z_wybranego_woj
FROM FIRMY 
JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
JOIN WOJ on WOJ.kod_woj = MIASTA.kod_woj
WHERE WOJ.kod_woj = @WOJ;


/* 3.3
poszuka� najwi�ksz� pensj� w bazie i pokaza� w jakiej firmie
i jaka osoba posiada
*/
DECLARE @MAX_PENS int;
SET @MAX_PENS = (SELECT MAX(ETATY.pensja) FROM ETATY); /* najwieksza pensja */

SELECT OSOBY.id_osoby, OSOBY.imie, OSOBY.nazwisko, FIRMY.nazwa
FROM OSOBY
JOIN ETATY on ETATY.id_osoby = OSOBY.id_osoby
JOIN FIRMY on FIRMY.nazwa_skr = ETATY.id_firmy
WHERE ETATY.pensja = @MAX_PENS; /* warunek na znalezienie najlepiej zar. osoby */


/* 2.4 */
IF OBJECT_ID(N'nowa_tab') IS not NULL DROP TABLE nowa_tab /* sprawdzenie czy tabela istnieje */

CREATE TABLE nowa_tab (
	kol1 NVARCHAR(100) NOT NULL
);
INSERT INTO nowa_tab (kol1)
VALUES ('rzad1'), ('rzad2'), ('rzad3');


SELECT * 
FROM nowa_tab

/* 2.5 */
IF OBJECT_ID(N'nowa_tab') IS NOT NULL /* sprawdzenie czy kolumna istnieje */
AND NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'nowa_kol'
			AND Object_ID = Object_ID(N'nowa_tab'))
BEGIN
	ALTER TABLE nowa_tab
	ADD nowa_kol DATETIME NOT NULL DEFAULT GETDATE();

	INSERT INTO nowa_tab (kol1)
	VALUES ('rzad4'), ('rzad5'), ('rzad6');
END

SELECT *
FROM nowa_tab
	
