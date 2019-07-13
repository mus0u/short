defmodule Short.Repo.Migrations.AddStatsToShortUrls do
  use Ecto.Migration

  def change do
    alter table("short_urls") do
      add :access_count, :integer, default: 0, null: false
    end
  end
end
