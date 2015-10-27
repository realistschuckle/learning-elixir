defmodule Rumbl.SessionController do
	use Rumbl.Web, :controller

	def new(conn, _) do
		conn
		|> render("new.html")
	end

	def create(conn, %{"s" => %{"password" => password, "username" => username}}) do
		conn
		|> Rumbl.Auth.login_by_username(username, password, repo: Repo)
		|> marshall_login
	end

	def delete(conn, _) do
		conn
		|> Rumbl.Auth.logout
		|> put_flash(:info, "You have been logged out.")
		|> redirect(to: page_path(conn, :index))
	end

	defp marshall_login({:ok, conn}) do
		conn
		|> put_flash(:info, "Welcome back!")
		|> redirect(to: page_path(conn, :index))
	end

	defp marshall_login({:error, _reason, conn}) do
		conn
		|> Rumbl.Auth.logout
		|> put_flash(:error, "Invalid username/password combination.")
		|> render("new.html")
	end
end
