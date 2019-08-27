defmodule DbFootprint.Install.CreateVersions do
	use Ecto.Migration

  def change do
  	create table(:versions) do
  		add :item_type, :string
  		add :item_id, :integer
  		add :event, :string
  		add :whodunnit, :string
  		add :object, :text 
  		timestamps()
  	end
  end
end