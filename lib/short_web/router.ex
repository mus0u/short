defmodule ShortWeb.Router do
  use ShortWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShortWeb do
    get "/shorten", ShortUrlController, :get_create

    get "/:slug", RedirectController, :do_redirect
    get "/:slug/stats", RedirectController, :stats
  end

  scope "/api", ShortWeb do
    pipe_through :api
    post "/short_url", ShortUrlController, :create
  end
end
