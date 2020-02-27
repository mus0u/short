defmodule ShortWeb.RedirectController do
  use ShortWeb, :controller

  alias Short.Shortening
  alias Short.Shortening.ShortUrl

  def do_redirect(conn, %{"slug" => slug}) do
    case Shortening.get_short_url_by_slug(slug) do
      %ShortUrl{url: url} = short_url ->
        conn =
          conn
          |> put_status(301)
          |> redirect(external: url)
        Shortening.increment_access_count(short_url)
        conn

      {:error, :not_found} ->
        handle_not_found(conn)
    end
  end

  def stats(conn, %{"slug" => slug}) do
    case Shortening.get_short_url_by_slug(slug) do
      %ShortUrl{} = short_url ->
        conn
        |> put_status(:ok)
        |> text("""
          url: #{short_url.url}
          short url: #{conn.scheme}://#{conn.host}/#{short_url.slug}
          access count: #{short_url.access_count}
        """)

      {:error, :not_found} ->
        handle_not_found(conn)
    end
  end

  defp handle_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> text("no short URL for that slug found.")
  end
end
