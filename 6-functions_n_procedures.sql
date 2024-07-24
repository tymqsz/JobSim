/*
Z6.1 Npisaæ procedurê, która
wyszuka osoby z województwa o kodzie @kod_woj (parametr proc)
które nie pracowa³a w firmie o nazwie
@nazwa nvarchar(100) - kolejny parametr

Wykonaæ testy i uzasadnic porawnoœæ
*/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'znajdz_osoby')
BEGIN
    DROP PROCEDURE znajdz_osoby;
END
GO

CREATE PROCEDURE znajdz_osoby(
	@kod_woj nchar(4),
	@nazwa nvarchar(100)
)
AS
BEGIN
	SELECT OSOBY.id_osoby
	FROM (
			SELECT OSOBY.id_osoby as id
			FROM OSOBY
			JOIN ETATY on ETATY.id_osoby = OSOBY.id_osoby
			JOIN FIRMY on FIRMY.nazwa_skr = ETATY.id_firmy
			WHERE FIRMY.nazwa = @nazwa) as odrzutki /* tabela pomocnicza zawierajaca osoby ktore pracwoaly w firmie */
	FULL JOIN OSOBY on OSOBY.id_osoby = odrzutki.id
	JOIN MIASTA on MIASTA.id_miasta = OSOBY.id_miasta
	JOIN WOJ on WOJ.kod_woj = MIASTA.kod_woj
	WHERE odrzutki.id is NULL AND WOJ.kod_woj = @kod_woj /* odrzucenie tych co pracowali i wymaganie odp. wojewodztwa */

END
GO

EXEC znajdz_osoby N'MAL', N'Brawl Stars'; /* powinno zwrocic nic */
EXEC znajdz_osoby N'MAZ', N'Brawl Stars';


/*
Z6.2
Napisaæ funkcjê, która dla parametrów
Nazwa z WOJ, nazwa z miasta, ulica z Firmy
stworzy napis( W:(nazwa z woj);M:(nazwa z miasta),UL:(ulica z firmy)

jak w FIRMY nie ma ULICA to porosze dodaæ
ALTER TABLE FIRMY ADD ULICA nvarchar(50) NOT NULL DEFAULT 'Pl.Politechniki'
i w paru firmach poustawiaæ wartoœci na inne

Napisaæ funkcjê, która dla parametrów
id_firmy, nazwa
stworzy napis( ID:(id_firmy);FI:20liter_z_nazwa_firmy)
napis max 30 znaków
*/

/* sprawdzenie istnienia kolumny*/
IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'FIRMY'
    AND COLUMN_NAME = 'ULICA'
)
BEGIN
    ALTER TABLE FIRMY
    ADD ULICA nvarchar(50) NOT NULL DEFAULT 'Pl.Politechniki';
END;

/* dodanie nazw ulic */
UPDATE FIRMY
SET ulica = 'Al.Jerozolimskie'
WHERE nazwa_skr = 'BS' OR nazwa_skr = 'CS'; 

UPDATE FIRMY
SET ulica = 'Nowowiejska'
WHERE nazwa_skr = 'DS' OR nazwa_skr = 'ES';

GO
DROP FUNCTION dbo.tworz_napis1; /* usun stara funkcje */

GO
CREATE FUNCTION dbo.tworz_napis1(
	@nazwa_woj nvarchar(30),
	@nazwa_miasta nvarchar(30),
	@ulica_firmy nvarchar(50)
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @result nvarchar(100);
	SET @result = CONCAT('W:(', @nazwa_woj, ');M:(', @nazwa_miasta, ');UL:(', @ulica_firmy, ')'); /* polacz napisy uzywajac concat() */
	RETURN @result;
END;
GO


SELECT dbo.tworz_napis1(WOJ.nazwa, MIASTA.nazwa, FIRMY.ulica) as napis1
FROM FIRMY
JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
JOIN WOJ on WOJ.kod_woj = MIASTA.kod_woj;

GO
DROP FUNCTION dbo.tworz_napis2;

GO
CREATE FUNCTION dbo.tworz_napis2(
	@id nchar(3),
	@nazwa nvarchar(30)
)
RETURNS nvarchar(30)
AS
BEGIN
	DECLARE @result nvarchar(30);
	SET @result = CONCAT('ID:(', @id, ');FI:(', LEFT(@nazwa, 20), ')');
	RETURN @result;
END;
GO

SELECT dbo.tworz_napis2(FIRMY.nazwa_skr, FIRMY.nazwa) as napis2
FROM FIRMY;


/*
Z 6.3
wykorzystaæ obie funkcje w procedure pokazuj¹cej firmy
w 2 kolumnach (funkcje z 6.2)
a parametrem nazwa województwa gdzie s¹ firmy
*/

GO
DROP PROCEDURE uzyj; /* usuniecie starej procedury*/

GO
CREATE PROCEDURE uzyj(
	@nazwa nvarchar(30)
)
AS
BEGIN
	/* wykorzystanie funkcji */
	SELECT dbo.tworz_napis1(WOJ.nazwa, MIASTA.nazwa, FIRMY.ulica) as napis1, dbo.tworz_napis2(FIRMY.nazwa_skr, FIRMY.nazwa) as napis2
	FROM FIRMY 
	JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
	JOIN WOJ on WOJ.kod_woj = MIASTA.kod_woj
	WHERE WOJ.nazwa = @nazwa;
END;
GO

EXEC uzyj N'Mazowieckie';

