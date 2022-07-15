/**************
| poplate_fk : script to generate random data into a child table with 
| Note that this script will require the original random data generator populate procedure(populate.sql)
| https://github.com/kedarvj/mysql-random-data-generator/blob/master/populate.sql
|
| USAGE: call populate_fk('DATABASE-NAME','CHILD-TABLE-NAME',NUMBER-OF-ROWS,DEBUG-MODE);
| EXAMPLE: call populate_fk('databasename','child',100,'N');
| Developer: Kedar Vaijanapurkar
| Website: http://kedar.nitty-witty.com/
|
**************/
DELIMITER $$

DROP PROCEDURE IF EXISTS populate_fk $$
CREATE PROCEDURE populate_fk(in_db varchar(50), in_table varchar(50), in_rows int, in_debug char(1)) 
fk_load:BEGIN

#select CONCAT("UPDATE ",TABLE_NAME," SET ",COLUMN_NAME,"=(SELECT ",REFERENCED_COLUMN_NAME," FROM ",REFERENCED_TABLE_SCHEMA,".",REFERENCED_TABLE_NAME," ORDER BY RAND() LIMIT 1);") into @query from information_schema.key_column_usage where TABLE_NAME=in_table AND TABLE_SCHEMA=in_db AND CONSTRAINT_NAME <> 'PRIMARY';
select concat("UPDATE ",in_table," SET ", (select GROUP_CONCAT(COLUMN_NAME,"=(SELECT ",REFERENCED_COLUMN_NAME," FROM ",REFERENCED_TABLE_SCHEMA,".",REFERENCED_TABLE_NAME," ORDER BY RAND() LIMIT 1)") from information_schema.key_column_usage where TABLE_NAME=in_table AND TABLE_SCHEMA=in_db AND CONSTRAINT_NAME <> 'PRIMARY' group by table_name),";" ) into @query;
	IF in_debug='Y' THEN
		select @query;
	END IF;
if @query is null then
select "No referential information found." as Error;
LEAVE fk_load;
end if;

set  foreign_key_checks=0;
call populate(in_db,in_table,in_rows,'N');
PREPARE t_stmt FROM @query;
EXECUTE t_stmt;

set  foreign_key_checks=1;

END
$$
DELIMITER ;
