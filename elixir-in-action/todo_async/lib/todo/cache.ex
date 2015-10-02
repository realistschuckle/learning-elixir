defmodule Todo.Cache do
	use GenServer

	def start do
		GenServer.start(__MODULE__, nil)
	end

	def server_process(cache_pid, name) do
		GenServer.call(cache_pid, {:server_process, name})
	end

	def init(_) do
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
