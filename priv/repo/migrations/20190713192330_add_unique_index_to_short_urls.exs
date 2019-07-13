defmodule Short.Repo.Migrations.AddUniqueIndexToShortUrls do
  use Ecto.Migration

  def change do
    create(unique_index("short_urls", :url))
  end
end
