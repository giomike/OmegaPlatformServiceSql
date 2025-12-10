/*
检查折扣票是否合法
# 2025.12.9
## 定义接口
## MIKE CHAN

*/
--DROP PROCEDURE SanseDW_Omega_POS_CheckDiscountTicket
--GO
CREATE PROCEDURE SanseDW_Omega_POS_CheckDiscountTicket
   @shopID          varchar(10),
   @tickID          varchar(20),
   @amount          money,
   @unitPriceAmount money,
   @styleID         varchar(20)=''
AS
   SET NOCOUNT ON;

   CREATE TABLE #ticketInfo
   (
      DiscountTicketID char( 15 ),
      Posted           int,
      Depose           int,
      PriceType        int,
      CheckID          char( 10 ),
      TakeEffectDt     datetime,
      LapseDate        datetime,
      Discount         numeric( 5, 4 ),
      UpperLimit       numeric( 16, 4 ),
      LowerLimit       numeric( 16, 4 ),
   )

   DECLARE @Msg varchar(256)

   INSERT #ticketInfo
          (DiscountTicketID,Posted,Depose,PriceType,CheckID,TakeEffectDt,LapseDate,Discount,UpperLimit,LowerLimit)
   SELECT DiscountTicketID,Posted,Depose,PriceType,CheckID,TakeEffectDt,LapseDate,Discount,UpperLimit,LowerLimit
   FROM   dbo.DiscountTicket(NOLOCK) a
   WHERE  DiscountTicketID = @tickID

   UPDATE a
   SET    a.Discount = b.Discount,
          a.UpperLimit = b.DiscountUpLimit,
          a.LowerLimit = b.DiscountDownLimit
   FROM   #ticketInfo a,
          dbo.DiscountTicketAdd(NOLOCK) b
   WHERE  a.DiscountTicketID = b.DiscountTicketID

   -- 校验是否存在折扣卷
   IF NOT EXISTS ( SELECT *
                   FROM   #ticketInfo )
      BEGIN
         SELECT -1 returnID,'没有存在有效的折扣卷' returnMessage,1 discount

         RETURN;
      END

   -- 校验折扣卷是否审核
   IF EXISTS ( SELECT *
               FROM   #ticketInfo a
               WHERE  a.Posted = 0 )
      BEGIN
         SELECT -2 returnID,'折扣卷还未审核' returnMessage,1 discount

         RETURN;
      END

   IF EXISTS ( SELECT *
               FROM   #ticketInfo a
               WHERE  a.Posted = 1 AND
                      a.Depose = 1 )
      BEGIN
         SELECT -3 returnID,'折扣卷已作废' returnMessage,1 discount

         RETURN;
      END

   -- 校验折扣卷的PriceType设置，1为按照吊牌价打折，0为按照现价打折，0暂时不开放，所以这里也限制
   IF EXISTS ( SELECT *
               FROM   #ticketInfo a
               WHERE  a.Posted = 1 AND
                      a.Depose = 0 AND
                      a.PriceType = 0 )
      BEGIN
         SELECT -4 returnID,'折扣卷不能使用，请核对折扣卷的PriceType设置' returnMessage,1 discount

         RETURN;
      END

   -- 判断折扣卷是否使用过
   IF EXISTS ( SELECT *
               FROM   #ticketInfo a
               WHERE  a.Posted = 1 AND
                      a.Depose = 0 AND
                      a.PriceType = 1 AND
                      isnull(a.CheckID, '') <> '' )
      BEGIN
         SELECT -5 returnID,'折扣卷已被使用' returnMessage,1 discount

         RETURN;
      END

   -- 校验折扣卷是否在有效时间内
   IF NOT EXISTS ( SELECT *
                   FROM   #ticketInfo a
                   WHERE  a.Posted = 1 AND
                          a.Depose = 0 AND
                          a.PriceType = 1 AND
                          GETDATE() >= a.TakeEffectDt AND
                          GETDATE() <= a.LapseDate )
      BEGIN
         SET @Msg = ''

         SELECT @Msg = '折扣卷当前不在有效时间内[' + CONVERT(VARCHAR(19), TakeEffectDt, 120) + ' 至 ' + CONVERT(VARCHAR(19), LapseDate, 120) + ']'
         FROM   #ticketInfo

         SELECT -6 returnID,@Msg returnMessage,1 discount

         RETURN;
      END

   -- 校验折扣卷的金额是否在设置的上下限内
   IF NOT EXISTS ( SELECT *
                   FROM   #ticketInfo a
                   WHERE  a.Posted = 1 AND
                          a.Depose = 0 AND
                          a.PriceType = 1 AND
                          a.UpperLimit >= @unitPriceAmount AND
                          a.LowerLimit <= @unitPriceAmount )
      BEGIN
         SET @Msg = ''

         SELECT @Msg = '折扣卷当前不在有效金额内[' + CONVERT(varchar, LowerLimit) + ' 至 ' + CONVERT(varchar, UpperLimit) + ']'
         FROM   #ticketInfo

         SELECT -6 returnID,@Msg returnMessage,1 discount

         RETURN;
      END

   -- 校验折扣卷的使用门店,DiscountTicketCust没有折扣卷数据默认所有门店可用
   IF EXISTS ( SELECT *
               FROM   #ticketInfo a,dbo.DiscountTicketCust(NOLOCK) b
               WHERE  a.DiscountTicketID = b.DiscountTicketID )
      BEGIN
         IF NOT EXISTS ( SELECT *
                         FROM   #ticketInfo a,dbo.DiscountTicketCust(NOLOCK) b
                         WHERE  a.DiscountTicketID = b.DiscountTicketID AND
                                b.Customer_ID = @shopID )
            BEGIN
               SELECT -7 returnID,'该折扣卷不是本门店电子折扣券' returnMessage,1 discount

               RETURN;
            END
      END

   -- 校验一下折扣卷是否支持购买该商品
   IF EXISTS ( SELECT *
               FROM   #ticketInfo a,dbo.DiscountTicketGoodsCondition(NOLOCK) b
               WHERE  a.DiscountTicketID = b.DiscountTicketID AND
                      b.GroupID = '1' AND
                      b.FieldName = 'Goods_No' )
      BEGIN
         IF @styleID = ''
            BEGIN
               SELECT -8 returnID,'该折扣卷限定商品使用' returnMessage,1 discount

               RETURN;
            END

         IF NOT EXISTS ( SELECT *
                         FROM   #ticketInfo a,dbo.DiscountTicketGoodsCondition(NOLOCK) b
                         WHERE  a.DiscountTicketID = b.DiscountTicketID AND
                                b.GroupID = '1' AND
                                b.FieldName = 'Goods_No' AND
                                b.[value] = @styleID )
            BEGIN
               SELECT -8 returnID,'该折扣卷不适用该商品' returnMessage,1 discount

               RETURN;
            END
      END

   DECLARE @DisCount numeric(5, 4)

   SELECT @DisCount = Discount
   FROM   #ticketInfo

   SELECT 1 returnID,'可以使用' returnMessage,@DisCount discount 
 
