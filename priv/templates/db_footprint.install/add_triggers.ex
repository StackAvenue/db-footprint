defmodule DbFootprint.Install.AddTriggers do
  use Ecto.Migration

  def create_trigger do
    execute "
      CREATE OR REPLACE FUNCTION log_create_changes()
      RETURNS trigger AS
      $BODY$
      BEGIN
         INSERT INTO versions(item_type, item_id, event, inserted_at)
         VALUES('employees', NEW.id, 'create', now());
       
        RETURN NEW;
      END;
      $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100
    "

    execute "
       CREATE TRIGGER log_create_changes
       AFTER INSERT
       ON employees
       FOR EACH ROW
       EXECUTE PROCEDURE log_create_changes();
    "
  end

  def update_trigger do
    execute "
      CREATE OR REPLACE FUNCTION log_update_changes()
      RETURNS trigger AS
      $BODY$
      BEGIN
         IF NEW <> OLD THEN
             INSERT INTO versions(item_type, item_id, event, inserted_at, object)
             VALUES('employees', OLD.id, 'update', now(), row_to_json(OLD));
         END IF;
       
         RETURN NEW;
      END;
      $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100
    "

    execute "
       CREATE TRIGGER log_update_changes
       AFTER UPDATE
       ON employees
       FOR EACH ROW
       EXECUTE PROCEDURE log_update_changes();
    "
  end

  def delete_trigger do
    execute "
      CREATE OR REPLACE FUNCTION log_delete_changes()
      RETURNS trigger AS
      $BODY$
      BEGIN
         INSERT INTO versions(item_type, item_id, event, inserted_at, object)
         VALUES('employees', OLD.id, 'destroy', now(), row_to_json(OLD));
       
        RETURN OLD;
      END;
      $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100
    "
    
    execute "
        CREATE TRIGGER log_delete_changes
        BEFORE DELETE
        ON employees
        FOR EACH ROW
        EXECUTE PROCEDURE log_delete_changes();
     "
  end

  def up do
    create_trigger()
    update_trigger()
    delete_trigger()
  end

  def down do
    execute "DROP TRIGGER IF EXISTS log_create_changes ON employees"
    execute "DROP TRIGGER IF EXISTS log_update_changes ON employees"
    execute "DROP TRIGGER IF EXISTS log_delete_changes ON employees"
  end
 end