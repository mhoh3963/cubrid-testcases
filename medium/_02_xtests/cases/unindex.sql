autocommit off;
create class foo (a int unique, b int);
create index i_foo_b on foo(b);
insert into foo values (1, 11);
insert into foo values (2, 12);
insert into foo values (3, 13);
insert into foo values (4, 14);
insert into foo values (5, 15);
insert into foo values (6, 16);
insert into foo(b) values(17);
insert into foo(b) values(18);
select * from foo;
rollback;