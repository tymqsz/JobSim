USE JobSimDB;

/*
Z4.1
najwi�ksza pensja z etat�w os�b o imieniu na (wybra� literk�) z miasta o nazwie ko�cz�cego si� na literk� (wybra�)
*/
DECLARE @imie_literka nchar(1) = 'A';
DECLARE @miasto_literka nchar(1) = 'e';

SELECT MAX(ETATY.pensja) as najwieksza_pensja
FROM ETATY 
JOIN OSOBY on OSOBY.id_osoby = ETATY.id_osoby
JOIN MIASTA on MIASTA.id_miasta = OSOBY.id_miasta
WHERE OSOBY.imie LIKE @imie_literka +'%'
AND MIASTA.nazwa LIKE '%' + @miasto_literka;

/*
doda� tak� sam� pensj� osobie o imieniu na inn� literk� ale z tego samego miasta
i sprawdzi� czy si� nie pokaze
jak si� pokaze to zapytanie jest zle
*/

DELETE FROM ETATY
WHERE ETATY.stanowisko = N'test';

INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES(1, N'CS', N'test', 999999999, '01-01-2010', '01-01-2028')

SELECT MAX(ETATY.pensja) as test1
FROM ETATY 
JOIN OSOBY on OSOBY.id_osoby = ETATY.id_osoby
JOIN MIASTA on MIASTA.id_miasta = OSOBY.id_miasta
WHERE OSOBY.imie LIKE @imie_literka +'%'
AND MIASTA.nazwa LIKE '%' + @miasto_literka;


/*
Z4.2
policzy� najwi�ksz� pensj� w kazdej z firm tylko z aktualnych etat�w
*/
SELECT akt_etaty.nazwa_firmy, MAX(akt_etaty.pensja)
FROM (	SELECT FIRMY.nazwa as nazwa_firmy, ETATY.pensja as pensja
		FROM ETATY
		JOIN FIRMY on FIRMY.nazwa_skr = ETATY.id_firmy
		WHERE GETDATE() BETWEEN ETATY.od AND ETATY.do ) AS akt_etaty
GROUP BY akt_etaty.nazwa_firmy;


/*
Z4.3
znalezc wojew�dztwa w kt�rych nie ma firmy z etatem o pensji mniejszej ni� X (wybra�)
*/
DECLARE @X INT = 10000;

/* wybierz te wojewodztwa ktore
   nie wystepuja wsrod tych gdzie pensja >@X */
SELECT WOJ.nazwa as dobre_woj
FROM WOJ 
FULL OUTER JOIN (	SELECT WOJ.nazwa as nazwa_woj
					FROM ETATY
					JOIN FIRMY on FIRMY.nazwa_skr = ETATY.id_firmy
					JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
					JOIN WOJ on WOJ.kod_woj = MIASTA.kod_woj
					WHERE ETATY.pensja > @X ) AS zle_woj
ON WOJ.nazwa = zle_woj.nazwa_woj
WHERE zle_woj.nazwa_woj is NULL
AND WOJ.kod_woj != N'???'; /* odrzuc nieznane woj */