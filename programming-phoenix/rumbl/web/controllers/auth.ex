defmodule Rumbl.Auth do
	import Plug.Conn
	import Comeonin.Bcrypt, only: [checkpw: 2]
	import Phoenix.Controller
	alias Rumbl.Router.Helpers

	def init(opts) do
		Keyword.fetch!(opts, :repo)
	end

	def call(conn, repo) do
		user_id = get_session(conn, :user_id)
		user = user_id && repo.get(Rumbl.User, user_id)
		assign(conn, :current_user, user)
	end

	def authenticate_user(conn, _) do
		conn.assigns.current_user
		|> do_authenticate_user(conn)
	end

	defp do_authenticate_user(nil, conn) do
		conn
		|> put_flash(:error, "You must be logged in to access that page.")
		|> redirect(to: Helpers.page_path(conn, :index))
		|> halt
	end

	defp do_authenticate_user(_, conn),
		do: conn

	def logout(conn) do
		conn
		|> delete_session(:user_id)
	end

	def login(conn, user) do
		conn
		|> assign(:current_user, user)
		|> put_session(:user_id, user.id)
		|> configure_session(renew: true)
	end

	def login_by_username(conn, username, password, opts) do
		repo = Keyword.fetch!(opts, :repo)
		user = repo.get_by(Rumbl.User, username: username)

		cond do
			user && checkpw(password, user.password_hash) -> {:ok, login(conn, user)}
			user -> {:error, :unauthorized, conn}
			true -> {:error, :not_found, conn}
		end
	end
end
