defmodule Todo.Server do
	use GenServer

	def add_entry(pid, date, title) do
		add_entry(pid, %{date: date, title: title})
	end
	
	def add_entry(pid, new_entry) do
		GenServer.cast(pid, {:add_entry, new_entry})
	end

	def entries(pid, date) do
		GenServer.call(pid, {:entries, date})
	end

	def whereis(name) do
		:gproc.whereis_name({:n, :l, {:todo_server, name}})
	end

	def start_link(name) do
		IO.puts("Starting to-do server for #{name}.")
		GenServer.start_link(Todo.Server, name, name: via_tuple(name))
	end

	def init(name) do
		{:ok, {Todo.Database.get(name) || Todo.List.new, name}}
	end

	def handle_cast({:add_entry, new_entry}, {list, name}) do
		new_state = Todo.List.add_entry(list, new_entry)
		Todo.Database.store(name, new_state)
		{:noreply, {new_state, name}}
	end

	def handle_call({:entries, date}, _, {list, _} = state) do
		{:reply, Todo.List.entries(list, date), state}
	end

	defp via_tuple(name) do
		{:via, :gproc, {:n, :l, {:todo_server, name}}}
	end
end
