USE [library]
GO


CREATE TRIGGER S_Cards_INSERT ON S_Cards
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorMessage nvarchar(max)='Transaction was canceled. ';
	DECLARE @RowCount int=0;
	SELECT @RowCount=COUNT(*) from inserted;
	IF @RowCount>1
		SET @ErrorMessage=@ErrorMessage+char(13)+char(10)+'Limit INSERT to a single row';


	/*1. ... Сделать так, чтобы нельзя было выдать книгу, которой уже нет в библиотеке (по количеству).*/
	IF EXISTS(SELECT * FROM Books JOIN Inserted ON Books.Id=Inserted.Id_Book WHERE Quantity=0)
		SET @ErrorMessage=@ErrorMessage+char(13)+char(10)+'Book is absent';
	
	/* 3. Чтобы нельзя было выдать более трёх книг одному студенту (имеется в виду количество книг на руках студента).*/
	IF (SELECT COUNT(*) FROM S_Cards WHERE S_Cards.Id_Student IN (SELECT Id_Student FROM Inserted) AND  S_Cards.DateIn IS NULL)>3
		SET @ErrorMessage=@ErrorMessage+char(13)+char(10)+'Max 3 books per student is allowed';
	
	/* 6. Нельзя выдать новую книгу студенту, если в прошлый раз он читал книгу дольше 2 месяцев!*/
	DECLARE @Id_Student int;
	SELECT @Id_Student=Inserted.Id_Student FROM Inserted;
	IF ((SELECT MAX(DATEDIFF(day, DateOut, ISNULL(DateIn, GETDATE())))  FROM S_Cards WHERE Id_Student=@Id_Student)>60)
		SET @ErrorMessage=@ErrorMessage+char(13)+char(10)+'You are not allowed to take the book because you exceed the time-limit last time';

	/* выполнение условий №1, 3, 6*/
	If LEN(@ErrorMessage)>26
	BEGIN
		ROLLBACK TRAN;
		THROW 50001, @ErrorMessage, 1;
	END
	

	/*1. Чтобы при взятии определенной книги, её количество уменьшалось на 1,
		а сам факт выдачи фиксировался в таблице Issued (в неё нужно записывать фамилию и имя студента/преподавателя, название книги, дату выдачи).*/
	INSERT Issued(VisitorName, VisitorSurname, BookTitle, DateOut)
	SELECT FirstName, LastName, Books.Name, DateOut 
	FROM inserted JOIN Students ON inserted.Id_Student=Students.Id JOIN Books ON inserted.Id_book=Books.id;
	
	UPDATE Books SET Quantity=Quantity-1  
	FROM Inserted WHERE Books.Id=Inserted.Id_Book AND Quantity>0;
	PRINT char(13)+char(10)+'->'+'Book was lent out';
	
	SET NOCOUNT OFF;
END;
go