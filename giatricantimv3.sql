-- https://stackoverflow.com/questions/591853/search-for-a-string-in-all-tables-rows-and-columns-of-a-db?rq=3
DECLARE
    @search_string  VARCHAR(100),
    @table_name     SYSNAME,
    @table_schema   SYSNAME,
    @column_name    SYSNAME,
    @sql_string     VARCHAR(2000)

SET @search_string = 'StringToFind'

DECLARE tables_cur CURSOR FOR SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'

OPEN tables_cur

FETCH NEXT FROM tables_cur INTO @table_schema, @table_name

WHILE (@@FETCH_STATUS = 0)
BEGIN
    DECLARE columns_cur CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @table_schema AND TABLE_NAME = @table_name AND COLLATION_NAME IS NOT NULL  -- Only strings have this and they always have it

    OPEN columns_cur

    FETCH NEXT FROM columns_cur INTO @column_name
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        SET @sql_string = 'IF EXISTS (SELECT * FROM ' + QUOTENAME(@table_schema) + '.' + QUOTENAME(@table_name) + ' WHERE ' + QUOTENAME(@column_name) + ' LIKE ''%' + @search_string + '%'') PRINT ''' + QUOTENAME(@table_schema) + '.' + QUOTENAME(@table_name) + ', ' + QUOTENAME(@column_name) + ''''

        EXECUTE(@sql_string)

        FETCH NEXT FROM columns_cur INTO @column_name
    END

    CLOSE columns_cur

    DEALLOCATE columns_cur

    FETCH NEXT FROM tables_cur INTO @table_schema, @table_name
END

CLOSE tables_cur

DEALLOCATE tables_cur
