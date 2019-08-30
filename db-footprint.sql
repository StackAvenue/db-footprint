CREATE TABLE employees(
   id SERIAL primary key,
   first_name varchar(40) NOT NULL,
   last_name varchar(40) NOT NULL
);

CREATE TABLE employee_audits (
   id SERIAL primary key,
   employee_id int4 NOT NULL,
   last_name varchar(40) NOT NULL,
   changed_on timestamp(6) NOT NULL
);

CREATE OR REPLACE FUNCTION log_all_changes()
  RETURNS trigger AS
$BODY$
BEGIN
   IF NEW <> OLD THEN
       INSERT INTO employee_audits(employee_id,first_name,last_name,changed_on)
       VALUES(OLD.id,OLD.first_name,OLD.last_name,now());
   END IF;
 
   RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100

CREATE TRIGGER log_all_changes
  BEFORE UPDATE
  ON employees
  FOR EACH ROW
  EXECUTE PROCEDURE log_all_changes();

SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM employee_audits;
SELECT * FROM employee_audits;
SELECT * FROM employees;

ALTER TABLE employee_audits
	ADD COLUMN first_name varchar(40);

UPDATE employees
SET first_name = 'Vikram'
WHERE id = 2;

INSERT INTO employees(first_name, last_name) VALUES ('Bandana', 'Pandey');

UPDATE employees SET first_name = 'Vikram' WHERE id = 2;

SELECT * FROM pg_trigger;

DELETE FROM pg_trigger WHERE tgname = 'last_name_changes';

DROP TRIGGER IF EXISTS all_changes ON employees;

DELETE FROM employee_audits;