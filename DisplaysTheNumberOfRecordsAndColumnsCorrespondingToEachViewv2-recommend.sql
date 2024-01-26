-- Sử dụng cơ sở dữ liệu của bạn
USE YourDatabaseName;

-- Tạo bảng tạm để lưu kết quả
CREATE TABLE #ViewRecordCount (ViewName NVARCHAR(128), RecordCount INT);

-- Lấy danh sách view từ cơ sở dữ liệu
DECLARE @viewName NVARCHAR(128);
DECLARE viewCursor CURSOR FOR
SELECT name FROM sys.views;

-- Lặp qua từng view và lấy số bản ghi
OPEN viewCursor;
FETCH NEXT FROM viewCursor INTO @viewName;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- In ra giá trị của biến @viewName
    -- PRINT '@viewName: ' + @viewName;

    DECLARE @sql NVARCHAR(MAX);

    -- Nếu viewName không có đóng mở ngoặc vuông ở đầu và cuối mà trong tên lại có dấu gạch ngang thì khi truy vấn đến view này sẽ bị lỗi
    IF ((CHARINDEX('[', @viewName) = 0 OR CHARINDEX(']', @viewName) = 0) AND CHARINDEX('-', @viewName) != 0)

    BEGIN
        SET @sql = N'INSERT INTO #ViewRecordCount (ViewName, RecordCount) ' + N'SELECT N''' + @viewName + ''', COUNT(*) FROM [' + @viewName + ']';
    END

    ELSE

    BEGIN
        SET @sql = N'INSERT INTO #ViewRecordCount (ViewName, RecordCount) ' + N'SELECT N''' + @viewName + ''', COUNT(*) FROM ' + @viewName;
    END

    -- In ra câu truy vấn động
    -- PRINT 'sql: ' + @sql;

    EXEC sp_executesql @sql;

    FETCH NEXT FROM viewCursor INTO @viewName;
END

-- Đóng con trỏ và xóa nó
CLOSE viewCursor;
DEALLOCATE viewCursor;

-- Truy vấn để lấy thông tin về view cùng với số cột
SELECT
    v.name AS ViewName,
    vr.RecordCount,
    COUNT(c.name) AS ColumnCount
FROM sys.views v
LEFT JOIN #ViewRecordCount vr ON v.name = vr.ViewName
LEFT JOIN sys.columns c ON v.object_id = c.object_id
GROUP BY v.name, vr.RecordCount
ORDER BY ViewName;

-- Xóa bảng tạm khi hoàn thành
DROP TABLE #ViewRecordCount;
