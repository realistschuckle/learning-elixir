defmodule Todo.Cache do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, nil, name: :todo_cache)
	end

	def server_process(name) do
		GenServer.call(:todo_cache, {:server_process, name})
	end

	def init(_) do
		IO.puts("Starting to-do cache.")
		Todo.Database.start("./persist/")
		{:ok, HashDict.new}
	end

	def handle_call({:server_process, name}, _, todo_servers) do
		case HashDict.fetch(todo_servers, name) do
			{:ok, todo_server} -> {:reply, todo_server, todo_servers}
			:error ->
				{:ok, new_server} = Todo.Server.start(name)
				{:reply, new_server, HashDict.put(todo_servers, name, new_server)}
		end
	end
end
