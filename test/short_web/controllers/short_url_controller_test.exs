defmodule Short.ShortUrlControllerTest do
  use ShortWeb.ConnCase

  alias Short.Shortening

  describe "GET / create" do
    test "returns a shortened URL on success", %{conn: conn} do
      path = Routes.short_url_path(conn, :get_create, %{uri: "https://crouton.net/"})
      resp =
        conn
        |> get(path)
        |> json_response(200)

      %{"short_url" => "http://localhost:8000/" <> slug} = resp
      assert String.length(slug) == 8
    end

    test "returns an error message when uri query parameter is missing", %{conn: conn} do
      path = Routes.short_url_path(conn, :get_create)
      resp =
        conn
        |> get(path)
        |> json_response(422)
      assert %{"errors" => [%{"missing query parameters" => ["uri"]}]} = resp
    end
  end

  describe "create" do
    test "returns a shortened URL on success", %{conn: conn} do
      params = %{
        payload: %{
          url: "https://crouton.net/"
        }
      }

      path = Routes.short_url_path(conn, :create)

      resp =
        conn
        |> post(path, params)
        |> json_response(201)

      %{
        "payload" => %{
          "url" => "https://crouton.net/",
          "short_url" => "http://localhost:8000/" <> slug
        }
      } = resp

      assert String.length(slug) == 8
    end

    test "returns an error when the url attribute is missing", %{conn: conn} do
      params = %{}
      path = Routes.short_url_path(conn, :create)
      conn = post(conn, path, params)
      resp = json_response(conn, 422)

      %{
        "errors" => [error]
      } = resp

      assert %{"missing_attributes" => ["url"]} == error
    end

    test "returns an error when the url attribute is invalid", %{conn: conn} do
      params = %{payload: %{url: 5}}
      path = Routes.short_url_path(conn, :create)
      conn = post(conn, path, params)
      resp = json_response(conn, 422)
      %{"errors" => [errors]} = resp
      %{"invalid_fields" => ["url"]} = errors
    end

    test "returns an error if the URL already exists", %{conn: conn} do
      {:ok, short_url} = Shortening.create_short_url(%{url: "http://crouton.net"})

      params = %{
        payload: %{
          url: short_url.url
        }
      }

      path = Routes.short_url_path(conn, :create)

      resp =
        conn
        |> post(path, params)
        |> json_response(422)

      %{"errors" => [errors]} = resp
      %{"invalid_fields" => ["url"]} = errors
    end
  end
end
