defmodule ShortWeb.ShortUrlController do
  use ShortWeb, :controller

  alias Plug.Conn
  alias Short.Shortening
  alias Short.Shortening.ShortUrl

  def get_create(conn, %{"uri" => url}) do
    with {:ok, short_url} <- Shortening.create_short_url(%{url: url}) do
      conn
      |> put_status(:ok)
      |> json(%{short_url: format_url(conn, short_url)})
    end
  end

  def get_create(conn, _) do
    error_response(conn, [%{"missing query parameters" => ["uri"]}])
  end

  def create(conn, params) do
    with {:ok, valid_params} <- create_params(params),
         {:ok, short_url} <- Shortening.create_short_url(valid_params) do
      response = %{
        payload: %{
          url: short_url.url,
          short_url: format_url(conn, short_url)
        }
      }

      conn
      |> put_status(:created)
      |> json(response)
    else
      {:error, missing_attributes: missing_attrs} ->
        error_response(conn, [%{missing_attributes: missing_attrs}])

      {:error, %Ecto.Changeset{} = changeset} ->
        invalid_fields = Enum.map(changeset.errors, fn {field_name, _} -> field_name end)
        formatted_errors = [%{invalid_fields: invalid_fields}]
        error_response(conn, formatted_errors)
    end
  end

  defp create_params(params) do
    case params do
      %{
        "payload" => %{
          "url" => url
        }
      } ->
        {:ok, %{url: url}}

      _other ->
        {:error, missing_attributes: [:url]}
    end
  end

  defp error_response(conn, errors) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: errors})
  end

  defp format_url(%Conn{scheme: scheme, host: host}, %ShortUrl{slug: slug}) do
    "#{scheme}://#{host}/#{slug}"
  end
end
