defmodule Short.Shortening.ShortUrl do
  use Short.Schema
  import Ecto.Changeset

  @valid_slug_chars Enum.reduce([?A..?Z, ?a..?z, ?0..?9], &Enum.concat/2)
  @slug_length 8

  schema "short_urls" do
    field :url, :string
    field :slug, :string
    field :access_count, :integer, default: 0

    timestamps()
  end

  @user_fields [:url]
  @required_fields [:slug, :access_count | @user_fields]

  def insert_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @user_fields)
    |> generate_slug()
    |> validate_required(@required_fields)
    |> validate_url()
    |> unique_constraint(:url)
  end

  def increment_count_changeset(%__MODULE__{} = short_url) do
    short_url
    |> cast(%{}, @required_fields)
    |> increment_count()
    |> validate_required(@required_fields)
  end

  defp validate_url(changeset) do
    validate_change(changeset, :url, fn :url, url ->
      case URI.parse(url) do
        %URI{} -> []
        _bad -> [url: "is invalid"]
      end
    end)
  end

  defp generate_slug(changeset) do
    slug =
      1..@slug_length
      |> Enum.map(fn _ -> Enum.random(@valid_slug_chars) end)
      |> List.to_string()

    put_change(changeset, :slug, slug)
  end

  defp increment_count(changeset) do
    access_count = get_field(changeset, :access_count)
    put_change(changeset, :access_count, access_count + 1)
  end
end
