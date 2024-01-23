USE YourDatabaseName; -- Thay thế YourDatabaseName bằng tên cơ sở dữ liệu của bạn

SELECT 
    t.name AS TableName,
    SUM(p.rows)/COUNT(c.name) AS RecordCount,
	COUNT(c.name) AS ColumnCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
LEFT JOIN sys.columns c ON t.object_id = c.object_id
WHERE p.index_id < 2 -- Lọc chỉ lấy dữ liệu thực tế, loại bỏ chỉ số như clustered index
GROUP BY t.name
ORDER BY TableName;
