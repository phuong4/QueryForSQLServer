DECLARE @SearchValueInside NVARCHAR(100);
SET @SearchValueInside = N'%StringToFind%'; -- Thay 'StringToFind' bằng tên chuỗi cần tìm

DECLARE @TableName NVARCHAR(128);
SET @TableName = 'TableName'; -- Thay 'TableName' bằng tên bảng cần tìm

-- Tạo bảng tạm để lưu kết quả
CREATE TABLE #SearchResults (TableName NVARCHAR(128), ColumnName NVARCHAR(128))

DECLARE @ColumnName NVARCHAR(128);
DECLARE column_cursor CURSOR FOR
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName;

OPEN column_cursor;
FETCH NEXT FROM column_cursor INTO @ColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- In ra giá trị của biến @SearchValueInside và @ColumnName
    -- PRINT 'SearchValueInside: ' + @SearchValueInside;
    -- PRINT 'ColumnName: ' + @ColumnName;

    DECLARE @SqlQuery NVARCHAR(MAX);

    SET @SqlQuery = N'
        INSERT INTO #SearchResults (TableName, ColumnName)
        SELECT ''' + @TableName + ''', ''' + @ColumnName + '''
        WHERE EXISTS (
            SELECT 1 
            FROM ' + @TableName + ' 
            WHERE CONVERT(NVARCHAR(MAX), ' + @TableName + '.[' + @ColumnName + ']) LIKE @SearchValueInside
        );
    ';

    -- In ra câu truy vấn động
    -- PRINT 'SqlQuery: ' + @SqlQuery;

    -- Thực hiện câu truy vấn động
    EXEC sp_executesql @SqlQuery, N'@SearchValueInside NVARCHAR(100)', @SearchValueInside;

    FETCH NEXT FROM column_cursor INTO @ColumnName;
END;

CLOSE column_cursor;
DEALLOCATE column_cursor;

-- Hiển thị kết quả
SELECT * FROM #SearchResults;

-- Xóa bảng tạm
DROP TABLE #SearchResults;
