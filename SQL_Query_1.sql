
SELECT si.[Stock Item] as [ProductName],
       SUM(s.Quantity) AS [SalesQuantity],
       SUM(s.[Total Excluding Tax]) AS [SalesRevenue],
       DATEPART(QUARTER, s.[Invoice Date Key]) AS [Quarter],
       DATEPART(YEAR, s.[Invoice Date Key]) AS [Year]
  FROM [Fact].[Sale] s
       INNER JOIN [Dimension].[Stock Item] si
               ON s.[Stock Item Key] = si.[Stock Item Key]
 WHERE s.[Stock Item Key] IN (
                              SELECT TOP 10 [Stock Item Key]
                                FROM [Fact].[Sale]
                               GROUP BY [Stock Item Key]
                               ORDER BY SUM([Total Excluding Tax]) DESC
                              )
 GROUP BY si.[Stock Item],
          DATEPART(QUARTER, s.[Invoice Date Key]),
          DATEPART(YEAR, s.[Invoice Date Key])
 ORDER BY [Year],
          [Quarter],
          [ProductName]
;