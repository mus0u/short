defmodule Short.ShorteningTest do
  use Short.DataCase
  alias Short.Repo
  alias Short.Shortening
  alias Shortening.ShortUrl

  describe "create_short_url/1" do
    test "creates a new ShortUrl" do
      url = "http://crouton.net"
      {:ok, %ShortUrl{url: ^url}} = Shortening.create_short_url(%{url: url})
    end
  end

  describe "get_short_url_by_slug/1" do
    test "retrieves the given ShortUrl by its slug" do
      {:ok, %ShortUrl{id: id, slug: slug, url: url}} =
        %{url: "http://crouton.net"}
        |> ShortUrl.insert_changeset()
        |> Repo.insert()

      %ShortUrl{id: ^id, slug: ^slug, url: ^url} = Shortening.get_short_url_by_slug(slug)
    end
  end

  describe "increment_access_count/1" do
    test "increments the access count of the given ShortUrl" do
      {:ok, short_url} =
        %{url: "http://crouton.net"}
        |> ShortUrl.insert_changeset()
        |> Repo.insert()

      {:ok, incremented} = Shortening.increment_access_count(short_url)
      assert incremented.access_count == short_url.access_count + 1
    end
  end
end
