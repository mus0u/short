defmodule Short.Shortening.AccessRecord do
  use Short.Schema
  import Ecto.Changeset
  alias Short.Shortening.ShortUrl

  schema "access_records" do
    belongs_to(:short_url, ShortUrl)

    timestamps()
  end

  @fields [:short_url_id]

  def insert_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
  end
end
