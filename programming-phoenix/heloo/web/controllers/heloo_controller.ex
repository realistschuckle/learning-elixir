defmodule Heloo.HelooController do
	use Heloo.Web, :controller

	def world(conn, %{"name" => name}) do
		render(conn, "world.html", name: name)
	end
end
