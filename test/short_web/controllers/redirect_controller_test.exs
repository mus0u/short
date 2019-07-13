defmodule ShortWeb.RedirectControllerTest do
  use ShortWeb.ConnCase

  alias Short.Repo
  alias Short.Shortening
  alias Short.Shortening.{AccessRecord, ShortUrl}

  describe "do_redirect" do
    test "redirects when the given slug exists, increments access_count, inserts access record",
         %{conn: conn} do
      {:ok, short_url} = Shortening.create_short_url(%{url: "http://crouton.net"})
      assert short_url.access_count == 0
      path = Routes.redirect_path(conn, :do_redirect, short_url.slug)
      conn = get(conn, path)
      assert redirected_to(conn) =~ "http://crouton.net"

      updated_short_url = Repo.get(ShortUrl, short_url.id)
      assert updated_short_url.access_count == 1
      access_record = Repo.get_by(AccessRecord, short_url_id: short_url.id)
      assert DateTime.to_date(access_record.inserted_at) == DateTime.to_date(DateTime.utc_now())
    end

    test "returns an error message when the slug does not exist", %{conn: conn} do
      path = Routes.redirect_path(conn, :do_redirect, "horsebeef")
      conn = get(conn, path)
      resp = text_response(conn, 404)
      assert resp == "no short URL for that slug found."
    end
  end

  describe "stats" do
    test "displays stats for a short url by slug", %{conn: conn} do
      {:ok, short_url} = Shortening.create_short_url(%{url: "http://crouton.net"})
      {:ok, short_url} = Shortening.increment_access_count(short_url)
      {:ok, short_url} = Shortening.increment_access_count(short_url)
      {:ok, short_url} = Shortening.increment_access_count(short_url)

      path = Routes.redirect_path(conn, :stats, short_url.slug)
      conn = get(conn, path)
      resp = text_response(conn, 200)

      assert """
               url: http://crouton.net
               short url: www.example.com/#{short_url.slug}
               access count: 3
             """ == resp
    end
  end
end
