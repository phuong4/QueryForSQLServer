USE NameDatabase; -- Replace 'NameDatabase' with the actual name of the database

-- Create a temporary results table
CREATE TABLE #SearchResults (TableName NVARCHAR(128), ColumnName NVARCHAR(128))

-- Replace 'StringToFind' with the value you want to find
DECLARE @SearchValue NVARCHAR(100) = 'StringToFind';

-- Create CURSOR to iterate through all tables
DECLARE @TableName NVARCHAR(128)
DECLARE @ColumnName NVARCHAR(128)

DECLARE TableCursor CURSOR FOR
SELECT t.name AS TableName, c.name AS ColumnName
FROM sys.tables AS t
INNER JOIN sys.columns AS c ON t.object_id = c.object_id

-- Loop through each table and execute the query
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName, @ColumnName

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @SqlQuery NVARCHAR(MAX)
    SET @SqlQuery = 'INSERT INTO #SearchResults (TableName, ColumnName) 
    SELECT ''' + @TableName + ''', ''' + @ColumnName + ''' WHERE EXISTS 
    (SELECT 1 FROM ' + @TableName + ' WHERE CAST([' + @ColumnName + '] AS NVARCHAR(MAX)) 
    LIKE ''%' + @SearchValue + '%'')'

    EXEC sp_executesql @SqlQuery

    FETCH NEXT FROM TableCursor INTO @TableName, @ColumnName
END

CLOSE TableCursor
DEALLOCATE TableCursor

SELECT * FROM #SearchResults;

-- Delete the temporary results table
DROP TABLE #SearchResults;
