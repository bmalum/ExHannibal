defmodule ExHannibal.LinkView do
  use ExHannibal.Web, :view

  def render("404.json", data) do
     %{http_error: 404}
  end
end
