/*
获取条码主数据
参数：
    @brand NVARCHAR(50) 品牌
    @timpStamp TIMESTAMP 时间戳
返回值：
    styleID 款号
    ColorID 颜色ID
    Long 长度
    SizeID 尺码ID
    BarCode 条码

# 2025-12-10
## 接口定义
## MIKECHAN
*/
DROP PROCEDURE if exists SanseDW_Omega_POS_GetBarcodeMaster
GO
CREATE PROCEDURE SanseDW_Omega_POS_GetBarcodeMaster
   @brand     nvarchar(50),
   @timpStamp timestamp
AS
   SELECT a.Goods_no styleID,a.ColorID,a.Long,a.Size,a.BarCode,b.UpdateTimestamp
   FROM   dbo.BarCode (NOLOCK) a,dbo.Goods (NOLOCK) b
   WHERE  a.Goods_no = b.Goods_no AND
          b.Brand = @brand AND
          b.UpdateTimestamp > @timpStamp AND
          LEFT(LTRIM(RTRIM(a.BarCode)), LEN(LTRIM(RTRIM(a.Goods_no)))) <> LTRIM(RTRIM(a.Goods_no))
   ORDER  BY b.UpdateTimestamp, a.Goods_No
GO

--exec SanseDW_Omega_POS_GetBarcodeMaster 'MM',0x00000000BFFC298B
 
