/*
获取当前生效的促销价格清单
# 2025-12-10
## 定义接口
## MIKE CHAN

# 2025-12-10
## 逻辑实现
## WDP
*/
--DROP PROCEDURE SanseDW_Omega_POS_GetCurrentPriceList
--GO
CREATE PROCEDURE SanseDW_Omega_POS_GetCurrentPriceList
   @shopID varchar(10)
AS
   SET NOCOUNT ON;

   -- 先全部获取满足生效时间的活动
   SELECT a.*
   INTO   #SPromoEx
   FROM   dbo.SPromoEx (NOLOCK) a,SPromoExCustomer (NOLOCK) B
   WHERE  a.Posted = 1 AND
          a.Cancel <> 1 AND
          GETDATE() BETWEEN a.TakeEffectDate AND a.LapseDate AND
          a.SPromoID = B.SPromoID AND
          B.FieldName = 'Customer_ID' AND
          B.Value = @shopID

   -- 剔除一些有特殊时间设置的活动
   BEGIN
      IF EXISTS ( SELECT *
                  FROM   #SPromoEx a,SPromoExMonth(NOLOCK) b
                  WHERE  a.SPromoID = b.SPromoID )
         BEGIN
            DELETE a
            FROM   #SPromoEx a,
                   SPromoExMonth(NOLOCK) b
            WHERE  a.SPromoID = b.SPromoID AND
                   DATEPART(mm, GETDATE()) <> b.[Month]
         END

      IF EXISTS ( SELECT *
                  FROM   #SPromoEx a,SPromoExDay(NOLOCK) b
                  WHERE  a.SPromoID = b.SPromoID )
         BEGIN
            DELETE a
            FROM   #SPromoEx a,
                   SPromoExDay(NOLOCK) b
            WHERE  a.SPromoID = b.SPromoID AND
                   DATEPART(dd, GETDATE()) <> b.[Day]
         END

      IF EXISTS ( SELECT *
                  FROM   #SPromoEx a,SPromoExWeek(NOLOCK) b
                  WHERE  a.SPromoID = b.SPromoID )
         BEGIN
            DELETE a
            FROM   #SPromoEx a,
                   SPromoExWeek(NOLOCK) b
            WHERE  a.SPromoID = b.SPromoID AND
                   (((@@DATEFIRST + DATEPART(weekday, GETDATE()) - 2) % 7) + 1) <> b.[Week]
         END

      IF EXISTS ( SELECT *
                  FROM   #SPromoEx a,SPromoExTime(NOLOCK) b
                  WHERE  a.SPromoID = b.SPromoID )
         BEGIN
            DELETE a
            FROM   #SPromoEx a,

                   SPromoExTime(NOLOCK) b
            WHERE  a.SPromoID = b.SPromoID AND
                   (GETDATE() < b.StartTime  OR
                    GETDATE() > b.EndTime)
         END
   END;

   WITH RankedPromotions
        AS ( SELECT a.SPromoID,a.SPromoTypeID,a.Description,a.TakeEffectDate,a.LapseDate,c.Goods_No,c.IsDiscount,c.Discount,c.UnitPrice,a.Priority,ISNULL(d.Value, '') AS PriceType,ROW_NUMBER()
                                                                                                                                                                                       OVER (
                                                                                                                                                                                          PARTITION BY c.Goods_No -- 按商品分组
                                                                                                                                                                                          ORDER BY DATEDIFF(Day, a.TakeEffectDate, GETDATE()), DATEDIFF(Day, GETDATE(), a.LapseDate), a.Priority, a.SPromoID ASC -- 按优先级升序排列（1为最高）
                                                                                                                                                                                       ) AS rn
             FROM   #SPromoEx a
                    INNER JOIN dbo.SPromoExSpType7(NOLOCK) c ON a.SPromoID = c.SPromoID
                    LEFT JOIN dbo.SPromoExProp(NOLOCK) d ON a.SPromoID = d.SPromoID AND
                                                            d.Name = 'VipNotDiscount' )
   SELECT @shopID AS ShopID, Goods_No AS StyleID,PriceType,UnitPrice AS Price,TakeEffectDate AS StartDate,LapseDate AS EndDate, [Description] Descr
   --SPromoID, SPromoTypeID, Description, TakeEffectDate, LapseDate, Goods_No, IsDiscount, Discount, UnitPrice, Priority, PriceType
   FROM   RankedPromotions
   WHERE  rn = 1 -- 只取每个商品的最高优先级记录
   ORDER  BY Priority,Goods_No; 