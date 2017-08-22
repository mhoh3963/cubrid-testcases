/*
Test Case: update & delete 
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test concurrent UPDATE/DELETE transactions in MVCC if using string function 
String Function(single): LTRIM

Test Scenario:
C1 update, C2 delete, the affected rows are not overlapped (based on where clause)
C1 update doesn't affect C2 delete
C1 uses LTRIM and C2 uses LTRIM
C1,C2's where clauses are on index (index scan)
C1 commit, C2 commit
Metrics: data size = small, index = function index(LTRIM), where clause = simple, schema = single table

Test Point:
1) C1 and C2 will not be waiting (Locking Test)
2) C1 instances will be updated, C2 instances will be deleted (Visibility Testing) 

NUM_CLIENTS = 3
C1: update table t1;   
C2: delete from table t1; 
C3: select on table t1; C3 is used to check the updated results 
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT PRIMARY KEY, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE INDEX idx_col_ltrim on t1(LTRIM(col));
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,' def ','C'),(4,'abc ','D'),(5,'def ','D'),(6,' abc','F'),(7,' def','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: UPDATE t1 SET tag = 'X' WHERE LTRIM(col) = 'abc'; 
MC: wait until C1 ready;

C2: DELETE FROM t1 WHERE LTRIM(col) = 'def'; 
/* expect: no transactions need to wait, assume C1 finished before C2 */
MC: wait until C2 ready;

/* expect: C1 select - id = 1,6 are updated */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;

/* expect: C2 select - id = 2,7 are deleted */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;

C1: commit;
MC: wait until C1 ready;

/* expect: C2 select - id = 1,6(C1) are updated, id = 2,7(C2) are deleted */
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;

/* expect: the instances of id = 1,6 are updated, id = 2,7 are deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
