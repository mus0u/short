defmodule ShortWeb.ShortUrlController do
  use ShortWeb, :controller

  alias Short.Shortening

  def create(conn, params) do
    with {:ok, valid_params} <- create_params(params),
         {:ok, short_url} <- Shortening.create_short_url(valid_params) do
      response = %{
        payload: %{
          url: short_url.url,
          short_url: conn.host <> "/" <> short_url.slug
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
    response = %{errors: errors}

    conn
    |> put_status(:unprocessable_entity)
    |> json(response)
  end
end
