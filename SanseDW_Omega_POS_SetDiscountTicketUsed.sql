/*
标记电子折扣券已经使用
# 2025.12.9 
## 定义接口
## Mike Chan

*/
DROP PROCEDURE SanseDW_Omega_POS_SetDiscountTicketUsed
GO
CREATE PROCEDURE SanseDW_Omega_POS_SetDiscountTicketUsed
   @shopID            VARCHAR(10),
   @ticketID          VARCHAR(20),
   @checkID           CHAR(10) = '',
   @omegaPosInvoiceID VARCHAR(30)
AS
   -- 记录一下使用日志
   
   -- 更新一下使用标识
   IF EXISTS ( SELECT *
               FROM   dbo.DiscountTicket(NOLOCK) a
               WHERE  a.DiscountTicketID = @ticketID AND
                      a.Posted = 1 AND
                      a.Depose = 0 AND
                      a.PriceType = 1 AND
                      ISNULL(a.CheckID, '') = '' )
      BEGIN
         UPDATE a
         SET    a.CheckID = @checkID
         FROM   dbo.DiscountTicket a
         WHERE  a.DiscountTicketID = @ticketID AND
                a.Posted = 1 AND
                a.Depose = 0 AND
                a.PriceType = 1 AND
                ISNULL(a.CheckID, '') = ''

         SELECT 1 returnID,'成功' returnMessage
      END
   ELSE
      BEGIN
         SELECT -1 returnID,'当前折扣卷已被使用' returnMessage
      END

 
