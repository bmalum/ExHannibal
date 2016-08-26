defmodule ExHannibal.PageController do
  use ExHannibal.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
