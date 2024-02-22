SELECT 
    DateDim.DateYear, ClubDim.ClubName, Game 
    SUM(CASE WHEN GameFact.GameResult = 'blue wins' THEN 1 ELSE 0 END) AS Wins, 
    SUM(CASE WHEN GameFact.GameResult = 'red wins' THEN 1 ELSE 0 END) AS Losses, 
    COUNT(*) AS TotalGames, 
    RANK() OVER (PARTITION BY DateDim.DateYear ORDER BY SUM(CASE WHEN GameFact.GameResult = 'blue wins' THEN 1 ELSE 0 END) DESC) AS RankByWins, 
 RANK() OVER (PARTITION BY DateDim.DateYear ORDER BY SUM(CASE WHEN GameFact.GameResult = 'red wins' THEN 1 ELSE 0 END) ASC) AS RankByLosses, 
    NTILE(4) OVER (PARTITION BY DateDim.DateYear ORDER BY SUM(CASE WHEN GameFact.GameResult = 'blue wins' THEN 1 ELSE 0 END) DESC) AS QuartileByWins 
FROM GameFact 
    JOIN PlayerInGameDim ON GameFact.GameID = PlayerInGameDim.GameID 
    JOIN PlayerDim ON PlayerInGameDim.PlayerID = PlayerDim.PlayerID 
    JOIN ClubDim ON PlayerInGameDim.ClubID = ClubDim.ClubID 
    JOIN DateDim ON GameFact.DateID = DateDim.DateID 
GROUP BY 
    DateDim.DateYear, 
    ClubDim.ClubName;

	SELECT TOP 10
    pd.PlayerGameName, 
    gd.GameStage, GameDuration,
    SUM(prd.PRKills) AS TotalKills, 
    SUM(prd.PRAssists) AS TotalAssists, 
    SUM(prd.PRDeaths) AS TotalDeaths, 
    RANK() OVER (ORDER BY SUM(prd.PRKills) + SUM(prd.PRAssists) - SUM(prd.PRDeaths) DESC) AS PlayerRank
FROM 
    PlayerDim pd
    JOIN PlayerInGameDim pigd ON pd.PlayerID = pigd.PlayerID
    JOIN GameDim gd ON gd.GameID = pigd.GameID
    JOIN GameFact gf ON gd.GameID = gf.GameID
    JOIN PersonalRecordDim prd ON prd.PRID = pigd.PRID
GROUP BY 
    pd.PlayerGameName, 
    gd.GameStage, GameDuration, 
    pd.PlayerID
HAVING GameStage = 'Play-in'
ORDER BY 
    PlayerRank ASC;


SELECT 
      DateDim.DateYear, 
      ProviderDim.ProviderName, 
      MerchandiseDim.MerchandiseType,
      SUM(EventFact.MerchandiseSold - RefundFact.MerchandiseRefunded ) AS TotalSales
   FROM 
      MerchandiseDim
      JOIN ProviderDim ON MerchandiseDim.MerchandiseProviderID = ProviderDim.ProviderID
      JOIN RefundFact ON MerchandiseDim.MerchandiseID = RefundFact.MerchandiseID
      JOIN DateDim ON DateDim.DateID = RefundFact.DateID 
      JOIN EventFact ON DateDim.DateID = EventFact.DateID
   GROUP BY
      DateDim.DateYear, 
      ProviderDim.ProviderName, 
      MerchandiseDim.MerchandiseType
 HAVING
     MerchandiseType = 'pins'
     ORDER BY DateYear, TotalSales DESC


	 SELECT 
    DateYear, 
    TicketEvent, 
    SUM(Bronze)  AS TotalBronzeTicketsSold, 
    SUM(Silver) AS TotalSilverTicketsSold, 
    SUM(Gold) AS TotalGoldTicketsSold
FROM 
    (
        SELECT 
            DateYear, 
            TicketEvent, 
            TicketType, 
            SUM(EventFact.TicketsSold) AS TotalTicketsSold
        FROM 
            TicketDim 
            JOIN EventFact ON TicketDim.TicketID = EventFact.TicketID
            JOIN DateDim ON DateDim.DateID = EventFact.DateID
        GROUP BY 
            DateYear, 
            TicketEvent, 
            TicketType
    ) AS src
PIVOT 
(
    SUM(TotalTicketsSold)
    FOR TicketType IN ([Gold], [Silver], [Bronze])
) AS pvt
GROUP BY 
    DateYear, 
    TicketEvent;


	SELECT CoachDim.CoachName, ClubDim.ClubName, AwardDim.AwardPosition, AwardDim.AwardValueInPND,
CoachYearsOfExperience,
ClubCoachDim.CoachPosition
FROM CoachDim
JOIN ClubCoachDim ON CoachDim.CoachID = ClubCoachDim.CoachID
JOIN ClubDim ON ClubCoachDim.ClubID = ClubDim.ClubID
JOIN AwardDim ON CoachDim.CoachHigherAwardID = AwardDim.AwardID
GROUP BY CoachDim.CoachName, ClubDim.ClubName, AwardDim.AwardPosition, AwardDim.AwardValueInPND,
ClubCoachDim.CoachPosition, CoachYearsOfExperience
ORDER BY AwardValueInPND DESC


SELECT MarketeerName, PromotionType, ISNULL([MSI], 0) AS [MSI], ISNULL([Worlds], 0) AS [Worlds]
FROM (
SELECT m.MarketeerName, p.PromotionType, e.EventName, p.PromotionDuration
FROM PromotionDim p
JOIN MarketeerDim m ON p.MarketeerID = m.MarketeerID
JOIN EventDim e ON p.PromotionEventID = e.EventID
) AS src
PIVOT (
SUM(PromotionDuration)
FOR EventName IN ([MSI], [Worlds])
) AS pvt
GROUP BY MarketeerName, PromotionType, [MSI], [Worlds]


SELECT 
    DateYear,
    EventName,
    TicketType,
    TicketEvent,
    SUM(EventFact.TicketsSoldPND) AS TotalRevenue,
    ROW_NUMBER() OVER (ORDER BY SUM(EventFact.TicketsSoldPND) DESC) AS revenue_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(EventFact.TicketsSold) DESC) AS tickets_sold_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY SUM(EventFact.TicketsSoldPND) DESC), 3) AS revenue_pct_rank,
    LAG(SUM(EventFact.TicketsSoldPND)) OVER (ORDER BY EventName, TicketType) AS previous_revenue,
    LEAD(SUM(EventFact.TicketsSoldPND)) OVER (ORDER BY EventName, TicketType) AS next_revenue
FROM 
    EventFact
    LEFT JOIN EventDim ON EventFact.EventID = EventDim.EventID
    LEFT JOIN TicketDim ON EventFact.TicketID = TicketDim.TicketID
    INNER JOIN DateDim ON EventFact.DateID = DateDim.DateID
GROUP BY 
    DateYear,
    EventName,
    TicketType,
    TicketEvent
ORDER BY
    DateYear


	SELECT
  PlayerRealName,
  SUM(PRKills) AS TotalKills,
  SUM(PRAssists) AS TotalAssists,
  SUM(PRDeaths) AS TotalDeaths,
  SUM((PRKills + PRAssists) / NULLIF(PRDeaths, 0)) AS TotalGame,
  DATEDIFF(year, PlayerDoB, GETDATE()) AS PlayerAge,
  RANK() OVER (ORDER BY SUM((PRKills + PRAssists) / NULLIF(PRDeaths, 0)) DESC) AS RankbyTotalGame
FROM
  PersonalRecordDim
  INNER JOIN PlayerInGameDim ON PersonalRecordDim.PRID = PlayerInGameDim.PRID
  LEFT JOIN PlayerDim ON PlayerInGameDim.PlayerID = PlayerDim.PlayerID
  INNER JOIN ChampionDim ON PlayerInGameDim.ChampionID = ChampionDim.ChampionID
GROUP BY
  PlayerRealName, PlayerDoB
ORDER BY
  TotalGame DESC;

SELECT 
  UPPER(Marketeername) AS MarketeerName,
  PromotionType,
  SUM(promotioncost) AS cost, 
  SUM(promotionrevenue) AS revenue,
  (SUM(promotionrevenue) - SUM(promotioncost)) AS profit,
  CASE 
    WHEN (SUM(promotionrevenue) - SUM(promotioncost)) < 49999 THEN 'Below Average' 
    WHEN (SUM(promotionrevenue) - SUM(promotioncost)) BETWEEN 50000 AND 69999 THEN 'Average' 
    WHEN (SUM(promotionrevenue) - SUM(promotioncost)) > 70000 THEN 'Above Average'   
  END AS 'Marketeer performance' 
FROM PromotionDim
JOIN eventfact ON promotiondim.promotionID = EventFact.promotionid 
JOIN marketeerdim ON marketeerdim.marketeerid = promotiondim.MarketeerID 
GROUP BY ROLLUP(PromotionType, MarketeerName);


SELECT
    EventYear,
    CASE WHEN EventName IS NULL THEN 'All Events' ELSE EventName END AS EventName,
    SUM(SpectatorsNumber) AS TotalSpectators,
    SUM(VIPSpectatorsNumber) AS Total_VIPSpectators,
    SUM(SpectatorsNumber + VIPSpectatorsNumber) - SUM(TicketsSold) AS Spectatorswithouttickets,
    RANK() OVER (PARTITION BY EventYear ORDER BY SUM(SpectatorsNumber) DESC) AS SpectatorsRank
FROM
    TicketDim
    INNER JOIN EventFact ON TicketDim.TicketID = EventFact.TicketID
    INNER JOIN EventDim ON EventFact.EventID = EventDim.EventID
GROUP BY GROUPING SETS((EventYear, EventName), (EventYear))
ORDER BY EventYear, SpectatorsRank;

SELECT 
  DateYear, 
  PromotionType, 
  (SUM(promotionrevenue) - SUM(promotioncost)) AS Promotionprofit,
  NTILE(4) OVER (ORDER BY (SUM(promotionrevenue) - SUM(promotioncost)) DESC) AS Quartile,
  ROUND(CUME_DIST() OVER (ORDER BY (SUM(promotionrevenue) - SUM(promotioncost)) ASC), 3) AS CumulativeDist
FROM 
  DateDim 
  RIGHT JOIN EventFact ON DateDim.DateID = EventFact.DateID 
  LEFT JOIN TicketDim ON EventFact.TicketID = TicketDim.TicketID 
  INNER JOIN PromotionDim ON EventFact.PromotionID = PromotionDim.PromotionID
WHERE DateYear = '2021'
GROUP BY 
  DateYear, 
  PromotionType
ORDER BY 
  (SUM(promotionrevenue) - SUM(promotioncost)) DESC;


