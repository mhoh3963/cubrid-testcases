/*
Test Case: delete & delete
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/delete_delete_02.ctl
Author: Ray

Test Plan: 
Test DELETE locks (X_LOCK on instance) if the delete instances of the transactions are not overlapped (with multiple pk schema)

Test Scenario:
The primary key is created on all(in this case: 2) the columns of the table
C1 delete, C2 delete, the affected rows are not overlapped
C1 commit, C2 commit
Metrics: schema = multi-pk, data size = small, where clause = simple, DELETE state = single table

Test Point:
1) C1 and C2 will not be waiting 
2) All the data affected from C1 and C2 should be deleted

NUM_CLIENTS = 3
C1: delete from table t1;  
C2: delete from table t1;  
C3: select on table t1; C3 is used to check the updated result
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
C1: CREATE TABLE t1(id INT, col VARCHAR(10), PRIMARY KEY(id, col));
C1: INSERT INTO t1 VALUES(1,'abc'),(2,'def'),(3,'ghi'),(4,'jkl'),(5,'mno'),(6,'pqr'),(7,'abc');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id > 4;
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE id < 4;
/* expect: no transactions need to wait */
MC: wait until C2 ready;
/* expect: C1 select - id = 5,6,7 are deleted */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;
/* expect: C2 select - id = 1,2,3 are deleted */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
/* expect: all the instances except id = 4 are deleted */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;




