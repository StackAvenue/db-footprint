defmodule DbFootprint.Install.AddTriggers do
  use Ecto.Migration

  def create_trigger do
    <%= for table <- tables do %>
      execute "
        CREATE OR REPLACE FUNCTION log_create_changes_<%= table %>()
        RETURNS trigger AS
        $BODY$
        BEGIN
           INSERT INTO versions(item_type, item_id, event, inserted_at)
           VALUES('<%= table %>', NEW.id, 'create', now());
         
          RETURN NEW;
        END;
        $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100
      "

      execute "
         CREATE TRIGGER log_create_changes_<%= table %>
         AFTER INSERT
         ON <%= table %>
         FOR EACH ROW
         EXECUTE PROCEDURE log_create_changes();
      "
    <% end %>
  end

  def update_trigger do
    <%= for table <- tables do %>
      execute "
        CREATE OR REPLACE FUNCTION log_update_changes_<%= table %>()
        RETURNS trigger AS
        $BODY$
        BEGIN
           IF NEW <> OLD THEN
               INSERT INTO versions(item_type, item_id, event, inserted_at, object)
               VALUES('<%= table %>', OLD.id, 'update', now(), row_to_json(OLD));
           END IF;
         
           RETURN NEW;
        END;
        $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100
      "

      execute "
         CREATE TRIGGER log_update_changes_<%= table %>
         AFTER UPDATE
         ON <%= table %>
         FOR EACH ROW
         EXECUTE PROCEDURE log_update_changes();
      "
    <% end %>
  end

  def delete_trigger do
    <%= for table <- tables do %>
      execute "
        CREATE OR REPLACE FUNCTION log_delete_changes()_<%= table %>
        RETURNS trigger AS
        $BODY$
        BEGIN
           INSERT INTO versions(item_type, item_id, event, inserted_at, object)
           VALUES('<%= table %>', OLD.id, 'destroy', now(), row_to_json(OLD));
         
          RETURN OLD;
        END;
        $BODY$
        LANGUAGE plpgsql VOLATILE
        COST 100
      "
      
      execute "
          CREATE TRIGGER log_delete_changes_<%= table %>
          BEFORE DELETE
          ON <%= table %>
          FOR EACH ROW
          EXECUTE PROCEDURE log_delete_changes();
       "
     <% end %>
  end

  def up do
    create_trigger()
    update_trigger()
    delete_trigger()
  end

  def down do
    <%= for table <- tables do %>
      execute "DROP TRIGGER IF EXISTS log_create_changes_<%= table %> ON <%= table %>"
      execute "DROP TRIGGER IF EXISTS log_update_changes_<%= table %> ON <%= table %>"
      execute "DROP TRIGGER IF EXISTS log_delete_changes_<%= table %> ON <%= table %>"
    <% end %>
  end
 end