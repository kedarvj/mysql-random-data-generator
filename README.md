# mysql-random-data-generator
This is the easiest MySQL Random Data Generator tool. Load the procedure and execute to auto detect column types and load data in it.


# Usage:

1. Download random data generater from website or git.

2. Load it to mysql
mysql -uUSER -p DBNAME < populate.sql

3. Use:
mysql>use DBNAME
mysql>call populate('sakila','film',100,'N');
# Parameters are: database-name, table-name, number-of-records, debug-mode
# Setting debug-mode as 'Y' will print all the insert statements that are being executed.

