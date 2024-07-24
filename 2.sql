USE JobSimDB;
/* Z2.1 */
/* Aktualizacja danych w tabeli MIASTA:
   - Dodanie kolumny [data uzyskania praw miejskich] typu datetime NULL.
   - Uzupe�nienie danej [data uzyskania praw miejskich] dla wybranych miast.
   - Utworzenie wirtualnej kolumny [od ilu lat prama miej], obliczaj�cej wiek prawa miejskiego w latach.
   - Zapytanie wybieraj�ce wszystkie miasta z dw�ch wybranych wojew�dztw, kt�re uzyska�y prawa miejskie co najmniej X lat temu, ale nie wi�cej ni� Y lat temu.
*/

UPDATE MIASTA SET prawa_miejskie_d = '01-01-1950' WHERE id_miasta = 1
UPDATE MIASTA SET prawa_miejskie_d = '08-01-1978' WHERE id_miasta = 2
UPDATE MIASTA SET prawa_miejskie_d = '02-08-2000' WHERE id_miasta = 3
UPDATE MIASTA SET prawa_miejskie_d = '03-04-1945' WHERE id_miasta = 4
UPDATE MIASTA SET prawa_miejskie_d = '04-03-1949' WHERE id_miasta = 5
UPDATE MIASTA SET prawa_miejskie_d = '05-02-1951' WHERE id_miasta = 6


/* wszystkie miasta z 2 wojew�dztw (wybra� dowolne 2)
** kt�re maj� prawa co najmniej X lat ale nie wi�cej jak Y lat */

Declare @X INT;
Declare @Y INT;
SET @X = 30;
SET @Y = 75;


SELECT MIASTA.nazwa as nazwa_miasta
FROM MIASTA JOIN WOJ ON MIASTA.kod_woj = WOJ.kod_woj
WHERE MIASTA.prawa_miejskie_d is not NULL AND
MIASTA.prawa_miejskie_len >= @X AND
MIASTA.prawa_miejskie_len < @Y AND
WOJ.nazwa = 'MAZOWIECKIE' OR
WOJ.nazwa = 'OPOLSKIE';


/* Z2.2
** zrobi� zapytania pokazuj�ce etaty
** dane etatu, nazwisko osoby, nazwa firmy, miast gdzie mieszka osoba, miasto gdzie znajduje si� firma
** wojew�dztwo miasta osoby
** wojew�dztwo miasta firmy
** takie ze osoba mieszka w wojwodztwie W (prosz� samemu kod wybra�)
** a firma jest w miescie X, kt�re jest w innym wojew�dztwie
** jak W */

Declare @wojew nvarchar(50);
Declare @miast nvarchar(50);

Set @wojew = N'Opolskie';
Set @miast = N'Dobre';

/* Zapytanie wybieraj�ce informacje o etatach:
   - Dane etatu, nazwisko osoby, nazwa firmy, miasto zamieszkania osoby, miasto siedziby firmy.
   - Wojew�dztwo miasta zamieszkania osoby i wojew�dztwo miasta siedziby firmy.
   - Wybrane wojew�dztwo dla miasta osoby (@wojew) oraz miasta firmy (@miast).
   - Ograniczenie wynik�w do przypadk�w, gdzie osoba mieszka w jednym wojew�dztwie, a firma znajduje si� w innym.
   - Zmiana danych osobowych lub firmowych w przypadku braku rekord�w spe�niaj�cych warunki.
*/
SELECT ETATY.*, OSOBY.nazwisko, FIRMY.nazwa as firma, miasto_osoby.nazwa as miasto_gdzie_mieszka,
	   miasto_firmy.nazwa as miasto_gdzie_firma, woj_osoby.nazwa as woj_gdzie_mieszka, woj_firmy.nazwa as woj_gdzie_firma 
FROM OSOBY
JOIN ETATY ON OSOBY.id_osoby = ETATY.id_osoby 
JOIN FIRMY ON ETATY.id_firmy = FIRMY.nazwa_skr
JOIN MIASTA miasto_osoby ON miasto_osoby.id_miasta = OSOBY.id_miasta
JOIN MIASTA miasto_firmy ON miasto_firmy.id_miasta = FIRMY.id_miasta 
JOIN WOJ woj_osoby on woj_osoby.kod_woj = miasto_osoby.kod_woj
JOIN WOJ woj_firmy on woj_firmy.kod_woj = miasto_firmy.kod_woj
WHERE woj_osoby.nazwa = @wojew AND
woj_osoby.nazwa != woj_firmy.nazwa;


/* Z2.3
** znale�� miasta z wojew�dztwa W
** kt�rych nazwa ko�czy si� na (wybra� literk�)
** i gdzie� w �rodku nazwy wojew�dztwa jest literka druga (wybrac jak� Pa�stwo chcecie)
*/

Set @wojew = N'Opolskie';

Declare @ostatnia nchar;
Declare @srodek nchar;

Set @ostatnia = N'n';
Set @srodek = N'e';

/* Zapytanie wybieraj�ce miasta z wybranego wojew�dztwa, kt�rych nazwa ko�czy si� na dan� liter� i zawiera drug� literk� w �rodku nazwy wojew�dztwa.
   - Wybranie wojew�dztwa dla poszukiwanych miast (@wojew).
   - Okre�lenie ko�cz�cej literki nazwy miasta (@ostatnia) oraz literki w �rodku nazwy wojew�dztwa (@srodek).
   - Sprawdzenie, czy nazwa miasta spe�nia warunki dotycz�ce ko�cz�cej si� litery oraz literki w �rodku nazwy wojew�dztwa.
*/
SELECT MIASTA.nazwa as nazwa_miasta
FROM MIASTA
JOIN WOJ ON MIASTA.kod_woj = WOJ.kod_woj
WHERE WOJ.nazwa = @wojew
AND MIASTA.nazwa LIKE N'%' + @ostatnia
AND WOJ.nazwa LIKE N'%' + @srodek + N'%';
