# mysql-random-data-generator
This is the easiest MySQL Random Data Generator tool. Load the procedure and execute to auto detect column types and load data in it.


# Usage:

1) Download random data generator (populate.sql and populate_fk.sql) from website or git.
- http://kedar.nitty-witty.com/blog/generate-random-test-data-for-mysql-using-routines

2) Load it to mysql

```
mysql -u USER -p DBNAME < populate.sql
mysql -u USER -p DBNAME < populate_fk.sql
```

3) Use:
```
mysql>use DBNAME

mysql>call populate('sakila','film',100,'N');
mysql>call populate_fk('sakila','child_table',100,'N');
```

- Parameters are: `database-name`, `table-name`, `number-of-records`, `debug-mode`
- Setting `debug-mode` as `Y` will print all the insert statements that are being executed.

