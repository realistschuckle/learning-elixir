defmodule Todo.Web do
	use Plug.Router

	plug :match
	plug :dispatch

	post "/add_entry" do
		conn
		|> Plug.Conn.fetch_params
		|> add_entry
		|> respond
	end

	get "/entries" do
		conn
		|> Plug.Conn.fetch_params
		|> fetch_entries
		|> respond
	end
	
	def start_server do
		case Application.get_env(:todo, :port) do
			nil -> raise("Todo port not specified")
			port -> Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
		end
	end

	defp add_entry(conn) do
		title = conn.params["title"]
		date = parse_date(conn.params["date"])
		
		conn.params["list"]
		|> Todo.Cache.server_process
		|> Todo.Server.add_entry(date, title)
		
		Plug.Conn.assign(conn, :response, "OK")
	end

	defp entries(name, date) do
		name
		|> Todo.Cache.server_process
		|> Todo.Server.entries(date)
		|> format_entries
	end

	defp fetch_entries(conn) do
		entries = entries(conn.params["list"], parse_date(conn.params["date"]))
		Plug.Conn.assign(conn, :response, entries)
	end

	defp format_entries(entries) do
		for entry <- entries do
			{y, m, d} = entry.date
			"#{y}-#{m}-#{d}  #{entry.title}"
		end
		|> Enum.join("\n")
	end

	defp respond(conn) do
		conn
		|> Plug.Conn.put_resp_content_type("text/plain")
		|> Plug.Conn.send_resp(200, conn.assigns[:response])
	end

	defp parse_date(date) do
		i = String.to_integer(date)
		{
			div(i, 10_000),
			div(rem(i, 10_000), 100),
			rem(i, 100)
		}
	end
end
