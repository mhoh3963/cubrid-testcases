/*
Test Case: insert & update
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
update many rows and rollback,another insert many rows and rollback
rollback many times

NUM_CLIENTS = 2
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: drop table if exists t1;
C1: create table t(id int,col int) partition by list(col)(partition p1 values in (1,2,3,4,5), partition p2 values in (6,7,8,9,10,11)); 
C1: create table t1(id int);
C1: insert into t1 values(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
C1: set @newincr=0;
C1: insert into t select (@newincr:=@newincr+1),a.id from t1 a,t1 b,t1 c,t1 d,t1 e,t1 f limit 100;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: update t set id=id+1,col=col+1;
MC: wait until C1 ready;

C2: insert into t select * from t;
MC: wait until C2 ready;

C1: rollback;
MC: wait until C1 ready;
MC: wait until C2 ready;

C2: rollback;
MC: wait until C2 ready;

C1: update t set id=id+1,col=col+1;
MC: wait until C1 ready;

C2: insert into t select * from t;
/*MC: wait until C2 ready;*/
MC: wait until C2 ready;


C1: rollback;
MC: wait until C1 ready;
MC: wait until C2 ready;

C2: rollback;
MC: wait until C2 ready;

C1: update t set id=id+1,col=col+1;
MC: wait until C1 ready;

C2: insert into t select * from t;
/*MC: wait until C2 ready;*/
MC: wait until C2 ready;

C1: rollback;
MC: wait until C1 ready;
MC: wait until C2 ready;

C2: rollback;
MC: wait until C2 ready;

/* expected 1000001 */
C2: select count(*) from t ;
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;
