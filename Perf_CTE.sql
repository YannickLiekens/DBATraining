/* CTEs
*/


/* CTEs are very good tool, look good and can be very useful, however, they don't always work as expected*/

;WITH Cte1
    AS ( SELECT u.Id FROM dbo.Users AS u WHERE u.Id = 1 )
SELECT *
FROM   Cte1;


/* Lets join it with itself*/

WITH Cte1
    AS ( SELECT u.Id FROM dbo.Users AS u WHERE u.Id = 1 )
SELECT *
FROM   Cte1
JOIN   Cte1 AS Cte2
    ON Cte2.Id = Cte1.Id;


/* Double the index seeks?!
*/


/* Every join will add another seek */

WITH Cte1
    AS ( SELECT u.Id FROM dbo.Users AS u WHERE u.Id = 1 )
SELECT *
FROM   Cte1
JOIN   Cte1 AS Cte2
ON Cte2.Id = Cte1.Id
JOIN   Cte1 AS Cte3
ON Cte3.Id = Cte1.Id

/*
Table 'Users'. Scan count 0, logical reads 9, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/





/* Is there a solution? */


SELECT * INTO #CteTempTable
FROM (
SELECT u.Id FROM dbo.Users AS u WHERE u.Id = 1
) Sq


SET STATISTICS TIME,IO ON
SELECT *
FROM   #CteTempTable AS Cte1
JOIN   #CteTempTable AS Cte2
ON Cte2.Id = Cte1.Id
JOIN   #CteTempTable AS Cte3
ON Cte3.Id = Cte1.Id

/*


Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table '#CteTempTable_______________________________________________________________________________________________________00000000001B'. Scan count 3, logical reads 3, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 33 ms.

   */


   /* Temp table has these advantages
   * logic only has to execute once
   * Keeps the plan simple, cte in cte in cte can lead to terrible plans
   * CAN BE INDEXED
   */