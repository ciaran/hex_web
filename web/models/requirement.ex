defmodule HexWeb.Requirement do
  use HexWeb.Web, :model

  schema "requirements" do
    field :app, :string
    field :requirement, :string
    field :optional, :boolean, default: false

    # The name of the dependency used to find the package
    field :name, :string, virtual: true

    belongs_to :release, Release
    belongs_to :dependency, Package
  end

  def changeset(requirement, params \\ %{}) do
    changeset = cast(requirement, params, ~w(name app requirement optional))

    name = changeset.changes.name
    app = Map.get(changeset.changes, :app, name)
    dep = HexWeb.Repo.get_by!(Package, name: name)

    changeset
    |> put_change(:app, app)
    |> put_change(:dependency_id, dep.id)
    |> validate_requirement
  end

  defp validate_requirement(changeset) do
    validate_change(changeset, :requirement, fn key, req ->
      cond do
        is_nil(req) ->
          # Temporary friendly error message until people update to hex 0.9.1
          [{key, "invalid requirement: #{inspect req}, use \">= 0.0.0\" instead"}]
        not valid?(req) ->
          [{key, "invalid requirement: #{inspect req}"}]
        true ->
          []
      end
    end)
  end

  defp valid?(req) do
    is_binary(req) and match?({:ok, _}, Version.parse_requirement(req))
  end
end
