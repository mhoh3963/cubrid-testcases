CREATE OR REPLACE FUNCTION test1() RETURN STRING AS LANGUAGE JAVA NAME 'SpTest9.testcatalog() RETURN java.lang.String';
CREATE OR REPLACE FUNCTION test2() RETURN STRING AS LANGUAGE JAVA NAME 'SpTest9.testtransactionisolation() RETURN java.lang.String';
CREATE OR REPLACE FUNCTION test3() RETURN STRING AS LANGUAGE JAVA NAME 'SpTest9.testautocommit() RETURN java.lang.String';

CALL test1();
CALL test2();
CALL test3();

DROP FUNCTION test1;
DROP FUNCTION test2;
DROP FUNCTION test3;