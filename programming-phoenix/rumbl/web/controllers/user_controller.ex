defmodule Rumbl.UserController do
	use Rumbl.Web, :controller

	plug :authenticate when action in [:index, :show]

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
		changeset = Rumbl.User.registration_changeset(%Rumbl.User{}, user_params)

		case Repo.insert(changeset) do
			{:ok, user} ->
				conn
				|> Rumbl.Auth.login(user)
				|> put_flash(:info, "#{user.name} created!")
				|> redirect(to: user_path(conn, :index))
			{:error, changeset} ->
				conn
				|> render("new.html", changeset: changeset)
		end
	end

	defp authenticate(conn, _) do
		conn.assigns.current_user
		|> authenticate_on_user(conn)
	end

	defp authenticate_on_user(nil, conn) do
		conn
		|> put_flash(:error, "You must be logged in to access that page.")
		|> redirect(to: page_path(conn, :index))
		|> halt
	end

	defp authenticate_on_user(_, conn),
		do: conn
end
