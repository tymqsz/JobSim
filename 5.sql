USE JobSimDB;

/*
Z5.1

Pokaza� MAX pensj� w ka�dym z miast ale tylko w tych w kt�rych �rednia pensja (AVG) jest
pomi�dzy A_MIN a A_MAX - prosz� sobie wybra�
*/

DECLARE @A_MIN MONEY = 1;
DECLARE @A_MAX MONEY = 100000000;

SELECT MIASTA.id_miasta, MAX(ETATY.pensja) as max_pensja
FROM FIRMY 
JOIN ETATY on ETATY.id_firmy = FIRMY.nazwa_skr
JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
GROUP BY MIASTA.id_miasta
HAVING AVG(ETATY.pensja) >= @A_MIN
AND AVG(ETATY.pensja) <= @A_MAX;


/*
Z5.2
Prosz� pokaza� kt�re miasto ma najwi�cej etat�w w bazie
etaty os�b mieszkaj�cych w [poszczegolnych] (?) miastach
Wymaga zapytania z grupowaniem i szukania po wyniku
*/

SELECT top 1 MIASTA.id_miasta, COUNT(*) as liczba_etatow
FROM FIRMY 
JOIN ETATY on ETATY.id_firmy = FIRMY.nazwa_skr
JOIN MIASTA on MIASTA.id_miasta = FIRMY.id_miasta
GROUP BY MIASTA.id_miasta
ORDER BY liczba_etatow DESC;

SELECT e.id_etatu as etaty_w_kornik
FROM ETATY e
JOIN FIRMY f ON e.id_firmy = f.nazwa_skr
JOIN MIASTA m ON f.id_miasta = m.id_miasta
WHERE m.nazwa = N'Kórnik';


SELECT e.id_etatu as etaty_w_dobra
FROM ETATY e
JOIN FIRMY f ON e.id_firmy = f.nazwa_skr
JOIN MIASTA m ON f.id_miasta = m.id_miasta
WHERE m.nazwa = N'Dobra';


SELECT e.id_etatu as etaty_w_ilza
FROM ETATY e
JOIN FIRMY f ON e.id_firmy = f.nazwa_skr
JOIN MIASTA m ON f.id_miasta = m.id_miasta
WHERE m.nazwa = N'Iłża';

SELECT e.id_etatu as etaty_w_dobrodzien
FROM ETATY e
JOIN FIRMY f ON e.id_firmy = f.nazwa_skr
JOIN MIASTA m ON f.id_miasta = m.id_miasta
WHERE m.nazwa = N'Dobrodzień';

/*
Z5.3

Prosz� doda� tabel�
CECHY (idc nchar(4) not null constraint PK_CECHY, opis nvarchar(100) not null)

Wpisac rekordy
N, Najlepszy
NZ, Najwi�ksze zarobki
SK, Super koledzy
�P, �atwe pieni�dze
SA, Super Zesp�
K, Kierownicze

i jeszcze ze 3

*/
IF OBJECT_ID(N'CECHY') IS NOT NULL
    DROP TABLE CECHY
GO
CREATE TABLE dbo.CECHY (
    idc nchar(4) NOT NULL CONSTRAINT PK_CECHY PRIMARY KEY,
    opis nvarchar(100) NOT NULL
)
INSERT INTO CECHY(idc, opis)
	VALUES (N'N', N'Najlepszy')
INSERT INTO CECHY(idc, opis)
	VALUES (N'NZ', N'Najwieksze zarobki')
INSERT INTO CECHY(idc, opis)
	VALUES (N'SK', N'Super koledzy')
INSERT INTO CECHY(idc, opis)
	VALUES (N'ŁP', N'Latwe pieniądze')
INSERT INTO CECHY(idc, opis)
	VALUES (N'SA', N'Super zespół')
INSERT INTO CECHY(idc, opis)
	VALUES (N'K', N'Kierownicze')
INSERT INTO CECHY(idc, opis)
	VALUES (N'OK', N'Okej')
INSERT INTO CECHY(idc, opis)
	VALUES (N'G', N'Głupi')
INSERT INTO CECHY(idc, opis)
	VALUES (N'BG', N'Bardzo głupi')
	
	
IF OBJECT_ID(N'ETATY_CECHY') IS NOT NULL
    DROP TABLE ETATY_CECHY
GO
CREATE TABLE dbo.ETATY_CECHY (
    id_etatu int NOT NULL CONSTRAINT FK_ETATU FOREIGN KEY references ETATY(id_etatu),
	idc nchar(4) NOT NULL,
    CONSTRAINT PK_ETATY_CECHY PRIMARY KEY (id_etatu, idc)
)

-- Insert for id_etatu = 1
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'N');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'SK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'ŁP');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'K');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'OK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'G');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (1, N'BG');

-- Insert for id_etatu = 2
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'N');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'SK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'ŁP');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'K');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'OK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'G');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (2, N'BG');

-- Insert for id_etatu = 3
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (3, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (3, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (3, N'K');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (3, N'OK');

-- Insert for id_etatu = 4
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (4, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (4, N'OK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (4, N'G');

-- Insert for id_etatu = 5
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (5, N'N');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (5, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (5, N'SK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (5, N'K');
-- Insert for id_etatu = 6
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (6, N'N');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (6, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (6, N'K');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (6, N'OK');

-- Insert for id_etatu = 7
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (7, N'N');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (7, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (7, N'ŁP');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (7, N'SA');

-- Insert for id_etatu = 8
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (8, N'SK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (8, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (8, N'K');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (8, N'OK');

-- Insert for id_etatu = 9
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (9, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (9, N'ŁP');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (9, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (9, N'K');

-- Insert for id_etatu = 10
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (10, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (10, N'SK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (10, N'ŁP');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (10, N'SA');

-- Insert for id_etatu = 11
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (11, N'K');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (11, N'OK');

-- Insert for id_etatu = 12
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (12, N'N');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (12, N'NZ');

-- Insert for id_etatu = 13
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (13, N'SK');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (13, N'ŁP');

-- Insert for id_etatu = 14
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (14, N'NZ');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (14, N'ŁP');

-- Insert for id_etatu = 15
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (15, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (15, N'K');

-- Insert for id_etatu = 16
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (16, N'SA');
INSERT INTO ETATY_CECHY (id_etatu, idc) VALUES (16, N'OK');

SELECT ec.id_etatu as etaty_z_3_cechami
FROM ETATY_CECHY ec
JOIN CECHY c ON ec.idc = c.idc
WHERE c.idc IN (N'SK', N'ŁP', N'NZ')
GROUP BY ec.id_etatu
HAVING COUNT(DISTINCT c.idc) = 3;

SELECT ec.id_etatu etaty_z_jakimis, COUNT(DISTINCT c.idc) as liczba_cech
FROM ETATY_CECHY ec
JOIN CECHY c ON ec.idc = c.idc
WHERE c.idc IN (N'SK', N'ŁP', N'NZ', N'N', N'G', N'BG')
GROUP BY ec.id_etatu
ORDER BY liczba_cech DESC;

/*

I stworzy� tabele ETATY_CECHY (id_etatu, idc)
obydwa jako klucze obce do tabel ETATY orac CECHY a klucz g�owny jako para id_etatu, idc
Stwory� zapytanie pokazuj�ce etaty maj�ce cechy SK, �P, NZ - wszystkie trzy musz� mie�
Oraz etaty maj�ce wszystkie powy�sze (doda� ze 2) lub mniej
posortowa� w kolejno�ci od etat�w maj�cych najwi�cej wybranych cech

Pozdrawiam
Maciej
*/