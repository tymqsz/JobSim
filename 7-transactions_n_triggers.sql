/* ZADANIE OSTATNIE - GRUPA PONIEDZIALKOWA */
/* utworzenie tabel */

IF(OBJECT_ID(N'ZAKUPY') is not null)
BEGIN
	DROP TABLE ZAKUPY;
END
IF(OBJECT_ID(N'SPRZED') is not null)
BEGIN
	DROP TABLE SPRZED;
END
IF(OBJECT_ID(N'MAGAZYN_PROD') is not null)
BEGIN
	DROP TABLE MAGAZYN_PROD;
END;

CREATE TABLE MAGAZYN_PROD(
	nazwa_prod nvarchar(30),
	id_prod int not null,
	liczba_zak int,
	liczba_dost int,
	PRIMARY KEY(id_prod)
);

CREATE TABLE ZAKUPY(
	id_zak int not null,
	id_prod int not null,
	liczba int,
	PRIMARY KEY(id_zak),
	FOREIGN KEY(id_prod) REFERENCES MAGAZYN_PROD(id_prod)
);


CREATE TABLE SPRZED(
	id_sprzed int not null,
	id_prod int not null,
	liczba int,
	PRIMARY KEY(id_sprzed),
	FOREIGN KEY(id_prod) REFERENCES MAGAZYN_PROD(id_prod)
);

/* triggery na MAGAZYN */

GO
IF(OBJECT_ID(N'NOWY_PROD') is not null)
BEGIN
	DROP TRIGGER NOWY_PROD
END

GO

CREATE TRIGGER NOWY_PROD ON MAGAZYN_PROD FOR INSERT
AS
	IF(EXISTS ( SELECT 1 FROM inserted))
	BEGIN
		UPDATE MAGAZYN_PROD SET liczba_zak = 0, liczba_dost = 0
		WHERE MAGAZYN_PROD.id_prod IN (SELECT id_prod FROM inserted)
	END
GO

IF(OBJECT_ID(N'NOWA_TRAN') is not null)
BEGIN
	DROP TRIGGER NOWA_TRAN
END
GO

CREATE TRIGGER NOWA_TRAN ON MAGAZYN_PROD FOR UPDATE
AS
	IF(UPDATE(liczba_zak) OR UPDATE(liczba_dost))
	BEGIN
		/* sprawdz czy ktoras dostawa < 0  i czy liczba_dost <= liczba_zak*/
		IF( (SELECT MIN(liczba_dost) FROM inserted) >= 0 AND
			(SELECT MIN(liczba_zak) FROM inserted) >= 0 AND
			NOT EXISTS( SELECT 1 from inserted WHERE inserted.liczba_dost > inserted.liczba_zak))
			BEGIN
				
				UPDATE MAGAZYN_PROD SET liczba_zak = inserted.liczba_zak , liczba_dost = inserted.liczba_dost
				FROM MAGAZYN_PROD INNER JOIN inserted ON MAGAZYN_PROD.id_prod = inserted.id_prod
			END
		ELSE
			BEGIN
				PRINT 'zly update magazyn';
				ROLLBACK TRAN;
			END
	END
GO

/* trigger na zakupy */

IF(OBJECT_ID(N'NOWY_ZAK_IN') is not null)
BEGIN
	DROP TRIGGER NOWY_ZAK_IN
END
GO

CREATE TRIGGER NOWY_ZAK_IN ON ZAKUPY FOR INSERT
AS
	/* dodanie zakupu */
	IF(EXISTS (SELECT 1 from inserted))
	BEGIN 
		/* update magazyn */
		WITH suma AS (
			SELECT 
				id_prod,
				SUM(liczba) AS liczba
			FROM 
				inserted
			GROUP BY 
				id_prod
		)
		UPDATE MAGAZYN_PROD SET liczba_zak = liczba_zak + suma.liczba,
								liczba_dost = liczba_dost + suma.liczba
		FROM MAGAZYN_PROD INNER JOIN suma on suma.id_prod = MAGAZYN_PROD.id_prod
	END
	ELSE
	BEGIN 
		print 'zly insert zakup';
		ROLLBACK TRAN
	END
GO


IF(OBJECT_ID(N'NOWY_ZAK_DEL') is not null)
BEGIN
	DROP TRIGGER NOWY_ZAK_DEL
END
GO

CREATE TRIGGER NOWY_ZAK_DEL ON ZAKUPY FOR DELETE
AS
	/* dodanie zakupu */
	IF(EXISTS (SELECT 1 from deleted))
	BEGIN 
		/* update magazyn */
		WITH suma AS (
			SELECT 
				id_prod,
				SUM(liczba) AS liczba
			FROM 
				deleted
			GROUP BY 
				id_prod
		)
		UPDATE MAGAZYN_PROD SET liczba_zak = liczba_zak - suma.liczba,
								liczba_dost = liczba_dost - suma.liczba
		FROM MAGAZYN_PROD INNER JOIN suma on suma.id_prod = MAGAZYN_PROD.id_prod; 
	END
	ELSE
	BEGIN 
		print 'zly delete zakup'
		ROLLBACK TRAN;
	END
GO

IF(OBJECT_ID(N'NOWY_ZAK_UP', 'TR') is not null)
BEGIN
	DROP TRIGGER NOWY_ZAK_UP
END
GO
CREATE TRIGGER NOWY_ZAK_UP ON ZAKUPY FOR UPDATE
AS
	/* dodanie zakupu */
	IF(UPDATE(liczba))
	BEGIN
		/* update magazyn */
		UPDATE MAGAZYN_PROD
        SET liczba_zak = liczba_zak + (i.liczba - d.liczba),
			liczba_dost = liczba_dost + (i.liczba - d.liczba)
        FROM MAGAZYN_PROD mp
        INNER JOIN inserted i ON mp.id_prod = i.id_prod
        INNER JOIN deleted d ON i.id_zak = d.id_zak;
	END
	ELSE
	BEGIN 
		print 'zly update zakup'
		ROLLBACK TRAN;
	END

GO

/* triggery na sprzedaz */

IF(OBJECT_ID(N'NOWA_SPRZED_IN') is not null)
BEGIN
	DROP TRIGGER NOWA_SPRZED_IN
END
GO

CREATE TRIGGER NOWA_SPRZED_IN ON SPRZED FOR INSERT
AS
	/* dodanie zakupu */
	IF(EXISTS (SELECT 1 from inserted))
	BEGIN 
		WITH suma AS (
			SELECT 
				id_prod,
				SUM(liczba) AS liczba
			FROM 
				inserted
			GROUP BY 
				id_prod
		)
		/* update magazyn */
		UPDATE MAGAZYN_PROD SET liczba_dost = liczba_dost - suma.liczba
		FROM MAGAZYN_PROD INNER JOIN suma on suma.id_prod = MAGAZYN_PROD.id_prod;
	END
	ELSE
	BEGIN 
		print 'zly insert sprzed';
		ROLLBACK TRAN
	END
GO


IF(OBJECT_ID(N'NOWA_SPRZED_DEL') is not null)
BEGIN
	DROP TRIGGER NOWA_SPRZED_DEL
END
GO

CREATE TRIGGER NOWA_SPRZED_DEL ON SPRZED FOR DELETE
AS
	/* dodanie zakupu */
	IF(EXISTS (SELECT 1 from deleted))
	BEGIN 
		/* update magazyn */
		WITH suma AS (
			SELECT 
				id_prod,
				SUM(liczba) AS liczba
			FROM 
				deleted
			GROUP BY 
				id_prod
		)
		UPDATE MAGAZYN_PROD SET liczba_dost = liczba_dost + suma.liczba
		FROM MAGAZYN_PROD INNER JOIN suma on suma.id_prod = MAGAZYN_PROD.id_prod; 
	END
	ELSE
	BEGIN 
		print 'zly delete sprzed'
		ROLLBACK TRAN;
	END
GO

IF(OBJECT_ID(N'NOWA_SPRZED_UP', 'TR') is not null)
BEGIN
	DROP TRIGGER NOWA_SPRZED_UP
END
GO
CREATE TRIGGER NOWA_SPRZED_UP ON SPRZED FOR UPDATE
AS
	IF(UPDATE(liczba))
	BEGIN
		/* update magazyn */
		UPDATE MAGAZYN_PROD
        SET liczba_dost = liczba_dost - (i.liczba - d.liczba)
        FROM MAGAZYN_PROD mp
        INNER JOIN inserted i ON mp.id_prod = i.id_prod
        INNER JOIN deleted d ON i.id_sprzed = d.id_sprzed;
	END
	ELSE
	BEGIN 
		print 'zly update zakup'
		ROLLBACK TRAN;
	END

GO


/* testy */

INSERT INTO MAGAZYN_PROD(nazwa_prod, id_prod, liczba_dost, liczba_zak)
VALUES 
	('a', 1, 2, 3),
	('b', 2, 3, 4),
	('c', 3, 4, 5),
	('d', 4, 4, 5),
	('3', 5, 4, 5)

-- dodawanie wielu zakupow naraz (+ te samo id_prod)
INSERT INTO ZAKUPY(id_zak, id_prod, liczba)
VALUES 
	(1, 1, 10),
	(2, 2, 20),
	(3, 3, 30),
	(4, 1, 100) -- powtorzone id_prod

	/*
SELECT * FROM MAGAZYN_PROD;
SELECT * FROM ZAKUPY;
*/
/* 
a	1	110	110 <- id 1. ma 10 + 100 = 110 
b	2	20	20
c	3	30	30
d	4	0	0
3	5	0	0
*/

--test update + delete
DELETE FROM ZAKUPY; -- wszystkie zakupy usuniete liczba_zak, liczba dost = 0, 0 w magazynie

INSERT INTO ZAKUPY(id_zak, id_prod, liczba)
VALUES 
	(1, 1, 10),
	(2, 2, 20),
	(3, 3, 30)

UPDATE ZAKUPY SET liczba = 99;

SELECT * FROM MAGAZYN_PROD;
SELECT * FROM ZAKUPY;


/*
na magazynie:
a	1	99	99
b	2	99	99
c	3	99	99

na zakupy:

1	1	99
2	2	99
3	3	99
*/


-- testy SPRZED
DELETE FROM ZAKUPY;
INSERT INTO ZAKUPY(id_zak, id_prod, liczba)
VALUES 
	(1, 1, 10),
	(2, 2, 20),
	(3, 3, 30),
	(4, 1, 100)
INSERT INTO SPRZED(id_sprzed, id_prod, liczba)
VALUES 
	(1, 1, 100),
	(2, 2, 3),
	(3, 3, 10)

SELECT * FROM MAGAZYN_PROD;
SELECT * FROM SPRZED;

/* 
magazyn:

a	1	110	10 <- dostepnych 110 - 100 = 10
b	2	20	17 <- 20- 3 = 17
c	3	30	20 <- 30 - 10 = 20
d	4	0	0
3	5	0	0

sprzed:
1	1	100
2	2	3
3	3	10

*/

-- testy update + delete SPRZED

UPDATE SPRZED SET liczba = 5;

SELECT * FROM MAGAZYN_PROD;
SELECT * FROM SPRZED;


/* 
magazyn:
a	1	110	105 dostepne = wszedzie -5 od zakupionych
b	2	20	15
c	3	30	25
d	4	0	0
3	5	0	0

sprzed:
1	1	5
2	2	5
3	3	5

*/

DELETE FROM SPRZED;

SELECT * FROM MAGAZYN_PROD;
SELECT * FROM SPRZED;

/*
stan magazynu - wszystkie liczba_zak = liczba_dost
a	1	110	110
b	2	20	20
c	3	30	30
d	4	0	0
3	5	0	0
*/


-- test sprzedazy zbyt duzej liczby produktu
/*
kwerenda:
INSERT INTO SPRZED(id_sprzed, id_prod, liczba)
VALUES 
	(99, 1, 10000)

zwraca blad:
zly update magazyn
Msg 3609, Level 16, State 1, Procedure NOWA_SPRZED_IN, Line 7 [Batch Start Line 267]
The transaction ended in the trigger. The batch has been aborted.
*/

/*


INSERT INTO MAGAZYN_PROD(nazwa_prod, id_prod, liczba_dost, liczba_zak)
VALUES 
	('a', 1, 2, 3),
	('b', 2, 3, 4),
	('c', 3, 4, 5)

INSERT INTO ZAKUPY(id_zak, id_prod, liczba)
VALUES 
	(1, 1, 10),
	(2, 2, 20),
	(3, 3, 400)

SELECT * FROM ZAKUPY;
SELECT * FROM MAGAZYN_PROD;


INSERT INTO SPRZED(id_sprzed, id_prod, liczba)
VALUES 
	(1, 1, 5),
	(2, 2, 10),
	(3, 3, 400)

SELECT * FROM ZAKUPY;
SELECT * FROM MAGAZYN_PROD;

DELETE FROM SPRZED WHERE id_sprzed = 3;



SELECT * FROM ZAKUPY;
SELECT * FROM MAGAZYN_PROD;

UPDATE SPRZED set liczba = 10 where id_sprzed = 1;

SELECT * FROM ZAKUPY;
SELECT * FROM MAGAZYN_PROD;
SELECT * FROM SPRZED;

*/
