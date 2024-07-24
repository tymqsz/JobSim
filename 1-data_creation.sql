USE JobSimDB;


/* ID_OSOBY w OSOBY i ID_MIASTA w MIASTA samonumeruj�ce IDENTITY
** to jedyne kolumny typu INT (jak i klucze obce do nich)
** OD i DO to DATETIME, PENSJA to MONEY, wszystkie pozosta�e 
** nchar i nvarchar. Jedyna typu NULL to DO w ETATY, pozosta�e NOT NULL
*/
IF OBJECT_ID(N'nowa_tabela') IS NOT NULL DROP TABLE nowa_tabela
IF OBJECT_ID(N'ETATY_CECHY') IS NOT NULL DROP TABLE ETATY_CECHY
IF OBJECT_ID(N'CECHY') IS NOT NULL DROP TABLE CECHY
IF OBJECT_ID(N'OSOBY') IS NOT NULL DROP TABLE OSOBY
IF OBJECT_ID(N'FIRMY') IS NOT NULL DROP TABLE FIRMY
IF OBJECT_ID(N'MIASTA') IS NOT NULL DROP TABLE MIASTA
IF OBJECT_ID(N'ETATY') IS NOT NULL DROP TABLE ETATY
IF OBJECT_ID(N'WOJ') IS NOT NULL DROP TABLE WOJ

CREATE TABLE dbo.WOJ 
(	kod_woj nchar(4)	NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY
,	nazwa	nvarchar(50) NOT NULL
)
GO
CREATE TABLE dbo.MIASTA
(	id_miasta	int				not null IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY
,	nazwa		nvarchar(50)	NOT NULL
,	kod_woj		nchar(4)		NOT NULL 
	CONSTRAINT FK_MIASTA_WOJ FOREIGN KEY REFERENCES WOJ(kod_woj),
	prawa_miejskie_d date NULL,
	prawa_miejskie_len AS DATEDIFF(YEAR, prawa_miejskie_d, GETDATE())
/* klucz obcy to powi�zanie do lucza g�ownego w innej tabelce
** typy kolumn musz� si� zgadzac - nazwy nie musz� */ 
)
GO
CREATE TABLE dbo.OSOBY
(	id_miasta	int				not null CONSTRAINT FK_OSOBY_MIASTA FOREIGN KEY
		REFERENCES MIASTA(id_miasta)
,	imie		nvarchar(50)	NOT NULL
,	nazwisko	nvarchar(50)	NOT NULL 
,	id_osoby int NOT NULL IDENTITY	CONSTRAINT PK_OSOBY PRIMARY KEY
/* klucz obcy to powi�zanie do lucza g�ownego w innej tabelce
** typy kolumn musz� si� zgadzac - nazwy nie musz� */ 
)
/* nie mo�na doda� miasta z nieznanym kodem woj */

CREATE TABLE dbo.ETATY
(
	id_osoby int,
	id_firmy nvarchar(50),
	stanowisko nvarchar(50),
	pensja int,
	od date,
	do date,
	id_etatu int not null IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY
)

CREATE TABLE dbo.FIRMY
(
    nazwa_skr nvarchar(50) not null CONSTRAINT FIRMY_PK PRIMARY KEY,
    id_miasta int not null CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY REFERENCES MIASTA(id_miasta),
    nazwa nvarchar(100),
    kod_pocztowy varchar(10),
    ulica nvarchar(50)
)


INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'???', N'<Nieznane>')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'MAZ', N'Mazowieckie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'OPO', N'Opolskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'WIE', N'Wielkopolske')

INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'WIE', N'Kórnik')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'WIE', N'Dobra')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'WIE', N'Ślesin')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'MAZ', N'Iłża')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'MAZ', N'Dobre')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'MAZ', N'Mordy')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'OPO', N'Niemodlin')
INSERT INTO MIASTA(kod_woj, nazwa) VALUES (N'OPO', N'Dobrodzień')

INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(5, N'El', N'Primo') /* > 1 */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(5, N'Ayumu', N'Kasuga') /* > 1 */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(6, N'Fryderyk', N'Chopin') /* > 1 */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(6, N'Sergiej', N'Rachmaninoff')
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(7, N'Friedrich', N'Nietzsche')
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(8, N'Peter', N'Griffin')
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(8, N'Stewie', N'Griffin') /* np */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(8, N'Meg', N'Griffin') /* np */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(4, N'Pablo', N'Mice') /* kiedys */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(1, N'Kruk', N'Crow') /* kiedys */
INSERT INTO OSOBY(id_miasta, imie, nazwisko) VALUES(1, N'Cyraneczka', N'Karolińska') /* niepracuje */

INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'BS', 1, N'Brawl Stars', '00-001', N'Based')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'CS', 2, N'Counter Strike', '00-002', N'Vertigo')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'DS', 3, N'Duzi Szwacze', '00-003', N'Ma�a')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'ES', 4, N'Łatwa Firma', '00-004', N'Du�a')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'FS', 5, N'Fotograficzny Sklep', '00-005', N'Sklepowa')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'GS', 6, N'Gorejące Skrzaty', '00-006', N'Fajna')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'HS', 7, N'Hardzi Softwerowcy', '00-007', 'Based')
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'IS', 8, N'Iskra Warszawa', '00-001', 'Siatkowa') /* bp */
INSERT INTO FIRMY(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica)
			VALUES(N'JS', 5, N'Javowe Skrypty', '00-001', 'Public Static Void') /* BP */
		
INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (1, N'BS', N'kozak', 999999, '2010-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (1, N'CS', N'kozak', 999999, '2015-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (2, N'DS', N'mysliciel', 999999999, '2000-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (2, N'ES', N'mysliciel', 999999, '2000-01-01', '2030-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (3, N'FS', N'gracz', 9, '2000-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (4, N'GS', N'kozak', 5, '2004-01-01', '2050-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (5, N'HS', N'scrum master', 1, '2023-01-01', '2024-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (6, N'BS', N'peter', 999, '2010-01-01', '2025-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (1, N'BS', N'programista', 10, '2010-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (1, N'BS', N'developer', 9, '2000-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (2, N'CS', N'sprzataczka', 9, '2010-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (3, N'CS', N'brawler', 3, '2010-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (3, N'CS', N'ml head', 2, '2010-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (3, N'ES', N'kursor', 2, '2010-01-01', '2028-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (9, N'FS', N'parser', 99, '2000-01-01', '2013-01-01');

INSERT INTO dbo.ETATY(id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (10, N'DS', N'kompilator', 999, '2000-01-01', '2015-01-01');