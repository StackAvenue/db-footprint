<% [head | _tail] = tables %>
defmodule <%= head  %>.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :item_type, :string
    field :item_id, :integer
    field :event, :string
    field :whodunnit, :string
    field :object, :string
    
    timestamps(updated_at: false)
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:item_type, :item_id, :event, :whodunnit, :object])
    |> validate_required([:item_type, :item_id, :event])
  end
end