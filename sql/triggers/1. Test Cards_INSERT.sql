USE [library]
GO

--Test Trigger Cards_INSERT
CREATE PROC [dbo].[Test_CardInsert_Date_In]
 @Table nvarchar(50),
 @PersonId int,
 @BookId int
 AS
 
if object_id('tempdb..#tmp_returned') IS NOT NULL
	DROP TABLE #tmp_returned;

select * into #tmp_returned from Issued;
Declare @NumberOfBooks int;
SELECT @NumberOfBooks=Quantity FROM Books WHERE Id=@BookId;
---------------------------------------------------------
	DECLARE @msg nvarchar(max)='INSERT '+@Table+
		' VALUES('+CAST(@PersonId AS nvarchar)+' ,'+ CAST(@BookId AS nvarchar)+', GETDATE(), NULL, 1)';
	EXEC(@msg);
---------------------------------------------------------

SELECT Name AS BookTitle, @NumberOfBooks AS PreviousQuantity, Quantity AS ActualQuantity FROM Books WHERE Id=@BookId;

SELECT * FROM Issued
EXCEPT
SELECT * FROM #tmp_returned;

EXEC('SELECT TOP 1 * FROM '+@Table+' ORDER BY Id DESC');
go


-----------------------------------------------------------------------
--exec Test_CardInsert_Date_In @Table='T_Cards', @PersonId=2, @BookId=1;
--exec Test_CardInsert_Date_In @Table='S_Cards', @PersonId=2, @BookId=1;

--insert s_cards values(2,1,getdate(),null, 1), (2,1,getdate(),null, 1), (2,1,getdate(),null, 1), (2,1,getdate(),null, 1);