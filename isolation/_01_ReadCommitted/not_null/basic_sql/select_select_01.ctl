/*
Test Case: select & select
Priority: 1
Reference case: 
Author: Ray

Test Plan: 
Test concurrent SELECT transactions in MVCC (with NOT NULL constraint)

Test Scenario:
C1 select, C2 select, the affected rows are not overlapped (based on where clause)
C1,C2 where clauses are on NOT NULL column (i.e. index scan)
C1 commit, C2 commit
Metrics: index = single index(Unique), data size = small, where clause = simple, schema = single table

Test Point:
1) C1 and C2 do not need to wait (Locking Test)
2) C1 instances should be selected from its original snapshot
   C2 instances should be selected from its original snapshot (Visibility Test)

NUM_CLIENTS = 2
C1: select from table t1;  
C2: select from table t1;  
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT NOT NULL, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE INDEX idx_id on t1(id);
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: SELECT * FROM t1 WHERE id >= 2 and id <= 4;
MC: wait until C1 ready;

C2: SELECT * FROM t1 WHERE id IN (5,7);
/* expect: no transactions need to wait */
MC: wait until C2 ready;
/* expect: C1 select - id = 2,3,4 are returned */
/* expect: C2 select - id = 5,7 are returned */
C1: commit;
MC: wait until C1 ready;

C2: commit;
MC: wait until C2 ready;


C1: quit;
C2: quit;
