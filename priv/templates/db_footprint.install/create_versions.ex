defmodule DbFootprint.Install.CreateVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :item_type, :string, null: false
      add :item_id, :integer, null: false
      add :event, :string, null: false
      add :whodunnit, :string
      add :object, :text
      timestamps()
    end
    create index(:versions, :item_type, :item_id)
  end
end