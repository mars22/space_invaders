defmodule SpaceInvadersWebWeb.PageController do
  use SpaceInvadersWebWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
