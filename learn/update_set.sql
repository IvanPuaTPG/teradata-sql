-- update table from another column

create TABLE cust_knowledge_db.ivan_test
(
id INT,
FIRST_NAME VARCHAR(15),
LAST_NAME VARCHAR(15)
)
PRIMARY INDEX (id)


INSERT INTO cust_knowledge_db.ivan_test VALUES (1,'Aman','Goyal');
INSERT INTO cust_knowledge_db.ivan_test VALUES (2,'Pritam','Soni');
INSERT INTO cust_knowledge_db.ivan_test VALUES (3,'Swati','Jain');


alter  table cust_knowledge_db.ivan_test
ADD rotational_flag INT;

create table cust_knowledge_db.ivan_rot_test(
	
	id INT,
	rotational INT
)
PRIMARY INDEX (id)

INSERT INTO cust_knowledge_db.ivan_rot_test VALUES (1,10);
INSERT INTO cust_knowledge_db.ivan_rot_test VALUES (2,20);
INSERT INTO cust_knowledge_db.ivan_rot_test VALUES (3,200);

select * from cust_knowledge_db.ivan_rot_test


Update cust_knowledge_db.ivan_test 
FROM (
	SELECT id, rotational
	from cust_knowledge_db.ivan_rot_test
	) b
set rotational_flag = b.rotational
where cust_knowledge_db.ivan_test.id = b.id;



SELECT * from cust_knowledge_db.ivan_test GEEK ORDER BY id;

DELETE FROM cust_knowledge_db.ivan_test WHERE id IS NULL

