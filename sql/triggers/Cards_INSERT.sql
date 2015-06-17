USE [library]
GO

CREATE TRIGGER T_Cards_INSERT ON T_Cards
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RowCount int=0;
	SELECT @RowCount=COUNT(*) from inserted;
	IF @RowCount>1
	THROW 50000, 'Transaction was canceled. Limit INSERT to a single row', 1;

	IF EXISTS(SELECT * FROM Books JOIN Inserted ON Books.Id=Inserted.Id_Book WHERE Quantity=0)
	THROW 50000, 'Book is absent', 1;
	
	INSERT Issued(VisitorName, VisitorSurname, BookTitle, DateOut)
	SELECT FirstName, LastName, Books.Name, DateOut 
	FROM inserted JOIN Teachers ON inserted.Id_Teacher=Teachers.Id JOIN Books ON inserted.Id_book=Books.id;
	
	UPDATE Books SET Quantity=Quantity-1  
	FROM Inserted WHERE Books.Id=Inserted.Id_Book AND Quantity>0;
	PRINT char(13)+char(10)+'->'+'Book was lent out';


	--SELECT Name AS [Book title], Quantity AS [Available amount], [Required Amount]
	--INTO #LackingBooks
	--FROM Books JOIN (SELECT Id_Book, COUNT(*) AS [Required Amount] FROM inserted GROUP BY Id_Book) AS InsertedBooks ON Books.Id=InsertedBooks.Id_Book
	--WHERE Quantity<[Required Amount]; 

	--IF (EXISTS(SELECT * FROM #LackingBooks))
	--BEGIN
	--	SELECT * FROM #LackingBooks;
	--	ROLLBACK TRAN;
	--	THROW 50000, 'Transaction was canceled because some books are absent/lacking (see detail in results)', 1;
	--END

	--INSERT Issued(VisitorName, VisitorSurname, BookTitle, DateOut)
	--SELECT FirstName, LastName, Books.Name, DateOut 
	--FROM inserted JOIN Teachers ON inserted.Id_Teacher=Teachers.Id JOIN Books ON inserted.Id_book=Books.id;
	
	--UPDATE Books SET Quantity=Quantity-BooksCount  
	--FROM (SELECT id_Book, COUNT(Id_Book) AS BooksCount FROM Inserted GROUP BY id_Book) AS ins WHERE Books.Id=ins.Id_Book AND Quantity>0;
	--PRINT char(13)+char(10)+'->'+'Books were lent out';
	
	SET NOCOUNT OFF;
END;
go

CREATE TRIGGER S_Cards_INSERT ON S_Cards
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RowCount int=0;
	SELECT @RowCount=COUNT(*) from inserted;
	IF @RowCount>1
	THROW 50000, 'Transaction was canceled. Limit INSERT to a single row', 1;

	IF EXISTS(SELECT * FROM Books JOIN Inserted ON Books.Id=Inserted.Id_Book WHERE Quantity=0)
	THROW 50000, 'Book is absent', 1;
	
	INSERT Issued(VisitorName, VisitorSurname, BookTitle, DateOut)
	SELECT FirstName, LastName, Books.Name, DateOut 
	FROM inserted JOIN Students ON inserted.Id_Student=Students.Id JOIN Books ON inserted.Id_book=Books.id;
	
	UPDATE Books SET Quantity=Quantity-1  
	FROM Inserted WHERE Books.Id=Inserted.Id_Book AND Quantity>0;
	PRINT char(13)+char(10)+'->'+'Book was lent out';
	
	SET NOCOUNT OFF;
END;
go

--test
insert s_cards values(2,1,getdate(),null, 1);
insert t_cards values(1,2,getdate(),null, 1)
insert t_cards values(1,1,getdate(),null, 1);
--/test