WITH Sales AS (
   SELECT s.[Stock Item Key],
          SUM(s.[Quantity])                             AS [SalesQuantity],
          SUM(s.[Total Excluding Tax])                  AS [SalesRevenue],
          d.[Quarter],
          d.[Year]
     FROM [Fact].[Sale] s
          INNER JOIN (SELECT MAX(Date)                  AS [LastDayofQuarter],
                            DATEPART(QUARTER, [Date])   AS [Quarter],
                       DATEPART(YEAR, [Date])           AS [Year]
                       FROM [Dimension].[Date]
                GROUP BY DATEPART(QUARTER, [Date]),
                         DATEPART(YEAR, [Date])
                      ) d
                ON s.[Invoice Date Key] <= d.[LastDayofQuarter]
    GROUP BY s.[Stock Item Key],
             d.[Quarter],
             d.[Year]
)
SELECT si.[Stock Item]                                                                 AS [ProductName],
      ([SalesRevenue] - 
       LAG(s.[SalesRevenue], 1) OVER (PARTITION BY s.[Stock Item Key]
                                          ORDER BY s.[Year], s.[Quarter]
                                      )
       ) / LAG(s.[SalesRevenue], 1) OVER (PARTITION BY s.[Stock Item Key]
                                              ORDER BY s.[Year], s.[Quarter]
                                          )
       * 100                                                                           AS [GrowthRevenueRate],
      (s.[SalesQuantity] - 
       LAG(s.[SalesQuantity], 1) OVER (PARTITION BY s.[Stock Item Key]
                                           ORDER BY s.[Year], s.[Quarter]
                                       )
      ) / CAST(LAG(s.[SalesQuantity], 1) OVER (PARTITION BY s.[Stock Item Key]
                                                   ORDER BY s.[Year], s.[Quarter]
                                               ) AS DECIMAL(15,2)
               )
       * 100                                                                           AS [GrowthQuantityRate],
      s.[Quarter]                                                                      AS [CurrentQuarter],
      s.[Year]                                                                         AS [CurrentYear],
      LAG(s.[Quarter], 1) OVER (PARTITION BY s.[Stock Item Key]
                                    ORDER BY s.[Year], s.[Quarter]
                                )                                                      AS [PreviousQuarter],
      LAG(s.[Year], 1) OVER (PARTITION BY s.[Stock Item Key]
                                 ORDER BY s.[Year], s.[Quarter]
                             )                                                         AS [PreviousYear]
  FROM Sales s
       INNER JOIN [Dimension].[Stock Item] si
              on s.[Stock Item Key] = si.[Stock Item Key]
 ORDER BY si.[Stock Item], s.[Year], s.[Quarter]
;