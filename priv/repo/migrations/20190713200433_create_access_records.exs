defmodule Short.Repo.Migrations.CreateAccessRecords do
  use Ecto.Migration

  def change do
    create table("access_records") do
      add :short_url_id, references("short_urls")

      timestamps()
    end
  end
end
