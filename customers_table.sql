use classicmodels;

describe information_schema.columns;

/* 1st test case */
show tables;

/* 2nd test case */
show tables;

/* 3rd test case */
SELECT count(*) AS NumberOfColumns
FROM information_schema.columns
WHERE table_name = 'customers';

/* 4th test case */
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'customers';

/* 5th test case */
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customers';

/* 6th test case */
SELECT column_name, column_type
FROM information_schema.columns
WHERE table_name = 'customers';

/* 7th test case */
SELECT column_name, is_nullable
FROM information_schema.columns
WHERE table_name = 'customers';

/* 8th test case */
SELECT column_name, column_key
FROM information_schema.columns
WHERE table_name = 'customers';

