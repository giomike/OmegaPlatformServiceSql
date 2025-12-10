/*
获取样式主数据存储过程
参数：
    @brand NVARCHAR(50) 品牌
    @timpStamp TIMESTAMP 时间戳

返回值：
    Goods_no StyleID 款号
    Goods_name NAME 名称
    [Range] [Range] 系列
    Pattern 图案
    [Item] 物料
    Category 分类
    Brand 品牌
    [Year] 年份
    Season 季节
    NewOld
    StartDate
    Sex
    UnitPrice 单价
    Size_class SizeClass 尺码类别
    Property 属性
    Designer 设计师
    Definition2 StockAge 库龄
    Definition19 Weight 重量
    Definition8 Buyer 采购员
    Category2 二级分类

# 2025-12-10
## 接口定义
## MIKECHAN
*/

DROP PROCEDURE SanseDW_Omega_POS_GetStyleMaster
GO
CREATE PROCEDURE SanseDW_Omega_POS_GetStyleMaster @brand NVARCHAR(50), @timpStamp TIMESTAMP
AS
SELECT Goods_no StyleID,
       Goods_name NAME,
       ISNULL([Range], '') [Range],
       Pattern,
       [Item],
       Category,
       Brand,
       [Year],
       Season,
       NewOld StartDate,
       Sex,
       UnitPrice,
       Size_class SizeClass,
       Property,
       Designer,
       Definition2 StockAge,
       Definition19 Weight,
	   Definition8 Buyer,
       Category2
FROM dbo.[Goods](NOLOCK) a
WHERE a.Brand = @brand
  AND a.Last_update_dt > @timpStamp
ORDER BY Goods_no
GO
