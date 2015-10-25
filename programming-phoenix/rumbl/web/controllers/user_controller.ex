defmodule Rumbl.UserController do
	use Rumbl.Web, :controller

	def index(conn, _params) do
		conn
		|> render("index.html", users: Repo.all(Rumbl.User))
	end

	def show(conn, %{"id" => id}) do
		conn
		|> render("show.html", user: Repo.get(Rumbl.User, id))
	end

	def new(conn, _params) do
		changeset = Rumbl.User.changeset(%Rumbl.User{})

		conn
		|> render("new.html", changeset: changeset)
	end

	def create(conn, %{"user" => user_params}) do
		changeset = Rumbl.User.changeset(%Rumbl.User{}, user_params)

		case Repo.insert(changeset) do
			{:ok, user} ->
				conn
				|> put_flash(:info, "#{user.name} created!")
				|> redirect(to: user_path(conn, :index))
			{:error, changeset} ->
				conn
				|> render("new.html", changeset: changeset)
		end
	end
end
