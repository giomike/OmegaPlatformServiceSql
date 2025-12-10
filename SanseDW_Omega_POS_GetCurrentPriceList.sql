/*
获取当前生效的促销价格清单
# 2025-12-10
## 定义接口
## MIKE CHAN


*/

DROP PROCEDURE SanseDW_Omega_POS_GetCurrentPriceList
GO
CREATE PROCEDURE SanseDW_Omega_POS_GetCurrentPriceList
   @shopID VARCHAR(10)
AS
   DECLARE @rtnPriceList TABLE
   (
      StyleID        VARCHAR(20),
      PriceType     INT,
      Price         MONEY,
      StartDate     DATETIME,
      EndDate       DATETIME
   )
   select styleID, PriceType, Price, StartDate, EndDate FROM @rtnPriceList
GO   
