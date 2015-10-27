defmodule Heloo.PageController do
  use Heloo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
