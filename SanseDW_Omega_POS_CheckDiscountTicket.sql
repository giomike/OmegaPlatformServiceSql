/*
检查折扣票是否合法
# 2025.12.9
## 定义接口
## MIKE CHAN

*/
DROP PROCEDURE SanseDW_Omega_POS_CheckDiscountTicket
GO
CREATE PROCEDURE SanseDW_Omega_POS_CheckDiscountTicket @shopID VARCHAR(10), @tickID VARCHAR(20), @amount MONEY, @unitPriceAmount MONEY
AS

DECLARE @rtn TABLE(returnID INT, returnMessage VARCHAR(256)，discountAmount MONEY);


INSERT @rtn
       (returnID,
        returnMessage, discountAmount)
VALUES ( 1,-- returnID - int
         '成功', 0 -- returnMessage - varchar(256), discountAmount - money
);

INSERT @rtn
       (returnID,
        returnMessage)
VALUES ( -1,-- returnID - int
         '不存在' -- returnMessage - varchar(256)
);

INSERT @rtn
       (returnID,
        returnMessage)
VALUES ( -2,-- returnID - int
         '超出限额' -- returnMessage - varchar(256)
); 

INSERT @rtn
       (returnID,
        returnMessage)
VALUES ( -3,-- returnID - int
         '不是本门店电子折扣券' -- returnMessage - varchar(256)
); 

SELECT a.returnID, a.returnMessage FROM @rtn a

GO


