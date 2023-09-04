WITH Sales AS (
SELECT 
       s.[Customer Key],
       SUM(s.Quantity)                                      AS [SalesQuantity],
       SUM(s.[Total Excluding Tax])                         AS [SalesRevenue],
       DATEPART(QUARTER, s.[Invoice Date Key])              AS [Quarter],
       DATEPART(YEAR, s.[Invoice Date Key])                 AS [Year]
  FROM [Fact].[Sale] s
 GROUP BY s.[Customer Key],
          DATEPART(QUARTER, s.[Invoice Date Key]),
          DATEPART(YEAR, s.[Invoice Date Key])
)
SELECT c.[Customer] AS     [ProductCategory],
       s.[SalesRevenue] /
       SUM(s.[SalesRevenue]) OVER (PARTITION BY s.[Year],
                                                s.[Quarter]
                            ) * 100                         AS [TotalRevenuePercentage],
       CAST(s.[SalesQuantity] AS DECIMAL(15,2)) /
       SUM(s.[SalesQuantity]) OVER (PARTITION BY s.[Year],
                                                 s.[Quarter]
                             ) * 100                        AS [TotalQuantityPercentage],
       s.[Quarter],
       s.[Year]
  FROM Sales s
       INNER JOIN [Dimension].[Customer] c
              ON s.[Customer Key] = c.[Customer Key]
;