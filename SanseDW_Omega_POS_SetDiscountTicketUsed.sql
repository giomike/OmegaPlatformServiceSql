/*
标记电子折扣券已经使用
# 2025.12.9 
## 定义接口
## Mike Chan

*/
DROP PROCEDURE SanseDW_Omega_POS_SetDiscountTicketUsed
GO
CREATE PROCEDURE SanseDW_Omega_POS_SetDiscountTicketUsed @shopID VARCHAR(10), @ticketID VARCHAR(20), @checkID CHAR(10) = '' , @omegaPosInvoiceID VARCHAR(30)
AS
DECLARE @rtn TABLE(returnID INT, returnMessage VARCHAR(256))

--要LOG一下什么核销单（销售单据）使用了这张DiscountTicket
INSERT @rtn
       (returnID,
        returnMessage)
VALUES ( 1,-- returnID - int
         '成功' -- returnMessage - varchar(256)
);

SELECT a.returnID, a.returnMessage FROM @rtn a
GO


