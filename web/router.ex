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
     scope "/v1" do
       get "/:api_key/", LinkController, :get_new_packages
       get "/:api_key/package/:package_hash", LinkController, :index
       get "/:api_key/package/_one_package", LinkController, :one_package
       post "/:api_key/package/:package_hash/_update_package", LinkController, :update_packagestate
       post "/:api_key/package/:package_hash/_update_linkstate", LinkController, :update_linkstate
       post "/:api_key/package/", LinkController, :add_package
     end
  end
end
