USE QLDD; -- Thay thế YourDatabaseName bằng tên cơ sở dữ liệu của bạn

SELECT
    v.name AS ViewName,
	SUM(p.rows) AS RecordCount, --RecordCount sẽ luôn trả về null, cách duy nhất để lấy được số bản ghi tương ứng với mỗi view là select COUNT(*) from ViewName
    COUNT(c.name) AS ColumnCount
FROM sys.views v
LEFT JOIN sys.partitions p ON v.object_id = p.object_id
LEFT JOIN sys.columns c ON v.object_id = c.object_id
GROUP BY v.name
ORDER BY ViewName;
