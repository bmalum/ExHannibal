defmodule ExHannibal.Router do
  use ExHannibal.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExHannibal do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ExHannibal do
     pipe_through :api
     scope "/v1", ExHannibal do
       get "/:api_key/_one_package", LinkController, :one_package
       post "/:api_key/_finished_package", LinkController, :finished_package
       post "/:api_key/_update_linkstate", LinkController, :update_linkstate
     end
  end
end
