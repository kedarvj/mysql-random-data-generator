DELIMITER $$

DROP PROCEDURE IF EXISTS populate $$
CREATE PROCEDURE populate(in_db varchar(50), in_table varchar(50), in_rows int, in_debug char(1)) 
BEGIN
/*
|
| Developer: Kedar Vaijanapurkar
| USAGE: call populate('DATABASE-NAME','TABLE-NAME',NUMBER-OF-ROWS,DEBUG-MODE);
| EXAMPLE: call populate('sakila','film',100,'N');
| Debug-mode will print an SQL that's executed and iterated.
|
*/

DECLARE col_name VARCHAR(100);
DECLARE col_type VARCHAR(100); 
DECLARE col_datatype VARCHAR(100);
DECLARE col_maxlen VARCHAR(100); 
DECLARE col_extra VARCHAR(100);
DECLARE col_num_precision VARCHAR(100);
DECLARE col_num_scale VARCHAR(100);
DECLARE func_query VARCHAR(1000);
DECLARE i INT;

DECLARE done INT DEFAULT 0;
DECLARE cur_datatype cursor FOR
 SELECT column_name,COLUMN_TYPE,data_type,CHARACTER_MAXIMUM_LENGTH,EXTRA,NUMERIC_PRECISION,NUMERIC_SCALE FROM information_schema.columns WHERE table_name=in_table AND table_schema=in_db;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


SET func_query='';
OPEN cur_datatype;
datatype_loop: loop

FETCH cur_datatype INTO col_name, col_type, col_datatype, col_maxlen, col_extra, col_num_precision, col_num_scale;
#SELECT CONCAT(col_name,"-", col_type,"-", col_datatype,"-", IFNULL(col_maxlen,'NULL'),"-", IFNULL(col_extra,'NULL')) AS VALS;
  IF (done = 1) THEN
    leave datatype_loop;
  END IF;

CASE 
WHEN col_extra='auto_increment' THEN SET func_query=concat(func_query,'NULL, ');
WHEN col_datatype in ('int','bigint') THEN SET func_query=concat(func_query,'get_int(), ');
WHEN col_datatype in ('varchar','char') THEN SET func_query=concat(func_query,'get_string(',ifnull(col_maxlen,0),'), ');
WHEN col_datatype in ('tinyint', 'smallint','year') or col_datatype='mediumint' THEN SET func_query=concat(func_query,'get_tinyint(), ');
WHEN col_datatype in ('datetime','timestamp') THEN SET func_query=concat(func_query,'get_datetime(), ');
WHEN col_datatype in ('date') THEN SET func_query=concat(func_query,'get_date(), ');
WHEN col_datatype in ('float', 'decimal') THEN SET func_query=concat(func_query,'get_float(',col_num_precision,',',col_num_scale,'), ');
WHEN col_datatype in ('enum','set') THEN SET func_query=concat(func_query,'get_enum("',col_type,'"), ');
WHEN col_datatype in ('GEOMETRY','POINT','LINESTRING','POLYGON','MULTIPOINT','MULTILINESTRING','MULTIPOLYGON','GEOMETRYCOLLECTION') THEN SET func_query=concat(func_query,'NULL, ');
ELSE SET func_query=concat(func_query,'get_varchar(',ifnull(col_maxlen,0),'), ');
END CASE;


end loop  datatype_loop;
close cur_datatype;

SET func_query=trim(trailing ', ' FROM func_query);
SET @func_query=concat("INSERT INTO ", in_db,".",in_table," VALUES (",func_query,");");
	IF in_debug='Y' THEN
		select @func_query;
	END IF;
SET i=in_rows;
populate :loop
	WHILE (i>0) DO
	  PREPARE t_stmt FROM @func_query;
	  EXECUTE t_stmt;
	SET i=i-1;
END WHILE;
LEAVE populate;
END LOOP populate;
SELECT "Kedar Vaijanapurkar" AS "Developed by";
END
$$
DELIMITER ;


	/************************
	END OF STORED PROCEDURE
	*************************/



/*
| Developer: Kedar Vaijanapurkar
| MySQL set of function to get random values generated for individual data-types.
*/

## MySQL function to generate random string of specified length
DROP function if exists get_string;
delimiter $$
CREATE FUNCTION get_string(in_strlen int) RETURNS VARCHAR(500) DETERMINISTIC
BEGIN 
set @var:='';
while(in_strlen>0) do
set @var:=concat(@var,IFNULL(ELT(1+FLOOR(RAND() * 53), 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',' ','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'),'Kedar'));
set in_strlen:=in_strlen-1;
end while;	
RETURN @var;
END $$
delimiter ;


## MySQL function to generate random Enum-ID from specified enum definition
DELIMITER $$
DROP FUNCTION IF EXISTS get_enum $$
CREATE FUNCTION get_enum(col_type varchar(100)) RETURNS VARCHAR(100) DETERMINISTIC
	RETURN if((@var:=ceil(rand()*10)) > (length(col_type)-length(replace(col_type,',',''))+1),(length(col_type)-length(replace(col_type,',',''))+1),@var);
$$
DELIMITER ;


## MySQL function to generate random float value from specified precision and scale.
DELIMITER $$
DROP FUNCTION IF EXISTS get_float $$
CREATE FUNCTION get_float(in_precision int, in_scale int) RETURNS VARCHAR(100) DETERMINISTIC
	RETURN round(rand()*pow(10,(in_precision-in_scale)),in_scale) 
$$
DELIMITER ;



## MySQL function to generate random date (of year 2012).
DELIMITER $$
DROP FUNCTION IF EXISTS get_date $$
CREATE FUNCTION get_date() RETURNS VARCHAR(10) DETERMINISTIC
	RETURN DATE(FROM_UNIXTIME(RAND() * (1356892200 - 1325356200) + 1325356200))
#	Below will generate random data for random years
#	RETURN DATE(FROM_UNIXTIME(RAND() * (1577817000 - 946665000) + 1325356200))
$$
DELIMITER ;


## MySQL function to generate random time.
DELIMITER $$
DROP FUNCTION IF EXISTS get_time $$
CREATE FUNCTION get_time() RETURNS INTEGER DETERMINISTIC
	RETURN TIME(FROM_UNIXTIME(RAND() * (1356892200 - 1325356200) + 1325356200))
$$
DELIMITER ;

## MySQL function to generate random int.
DELIMITER $$
DROP FUNCTION IF EXISTS get_int $$
CREATE FUNCTION get_int() RETURNS INTEGER DETERMINISTIC
	RETURN floor(rand()*10000000) 
$$
DELIMITER ;

## MySQL function to generate random tinyint.
DELIMITER $$
DROP FUNCTION IF EXISTS get_tinyint $$
CREATE FUNCTION get_tinyint() RETURNS INTEGER DETERMINISTIC
	RETURN floor(rand()*100) 
$$
DELIMITER ;

## MySQL function to generate random varchar column of specified length(alpha-numeric string).
DELIMITER $$
DROP FUNCTION IF EXISTS get_varchar $$
CREATE FUNCTION get_varchar(in_length varchar(500)) RETURNS VARCHAR(500) DETERMINISTIC
	RETURN SUBSTRING(MD5(RAND()) FROM 1 FOR in_length)
$$
DELIMITER ;

## MySQL function to generate random datetime value (any datetime of year 2012).
DELIMITER $$
DROP FUNCTION IF EXISTS get_datetime $$
CREATE FUNCTION get_datetime() RETURNS VARCHAR(30) DETERMINISTIC
	RETURN FROM_UNIXTIME(ROUND(RAND() * (1356892200 - 1325356200)) + 1325356200)
$$
DELIMITER ;

