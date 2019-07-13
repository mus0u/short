defmodule Short.Repo.Migrations.CreateShortUrls do
  use Ecto.Migration

  def change do
    create table("short_urls") do
      add :url, :string, null: false
      add :slug, :string, null: false

      timestamps()
    end
  end
end
