defmodule HexWeb.PackageMetadata do
  use HexWeb.Web, :model

  embedded_schema do
    # TODO: contributors is depracated, use maintainers
    field :contributors, {:array, :string}
    field :description, :string
    field :licenses, {:array, :string}
    field :links, :map
    field :maintainers, {:array, :string}
  end

  def changeset(meta, params \\ %{}) do
    cast(meta, params, ~w(description contributors licenses links maintainers))
    |> validate_required(:description)
  end
end
