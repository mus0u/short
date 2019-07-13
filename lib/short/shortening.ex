defmodule Short.Shortening do
  alias Short.Repo
  alias Short.Shortening.{AccessRecord, ShortUrl}
  alias Short.Cache.ShortUrlCache

  def create_short_url(%{url: url}) do
    result =
      %{url: url}
      |> ShortUrl.insert_changeset()
      |> Repo.insert()

    case result do
      {:ok, short_url} ->
        ShortUrlCache.set(short_url.slug, short_url)
        {:ok, short_url}

      other ->
        other
    end
  end

  def get_short_url_by_slug(slug) do
    case ShortUrlCache.get(slug) do
      {:found, short_url} ->
        short_url

      {:not_found} ->
        case Repo.get_by(ShortUrl, slug: slug) do
          %ShortUrl{} = short_url ->
            ShortUrlCache.set(short_url.slug, short_url)
            short_url

          nil ->
            {:error, :not_found}
        end
    end
  end

  def increment_access_count(%ShortUrl{} = short_url) do
    result =
      Repo.transaction(fn ->
        {:ok, short_url} =
          short_url
          |> ShortUrl.increment_count_changeset()
          |> Repo.update()

        %{short_url_id: short_url.id}
        |> AccessRecord.insert_changeset()
        |> Repo.insert()

        short_url
      end)

    case result do
      {:ok, short_url} ->
        ShortUrlCache.set(short_url.slug, short_url)
        {:ok, short_url}

      other ->
        other
    end
  end
end
