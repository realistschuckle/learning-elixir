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

	def start(name) do
		GenServer.start(Todo.Server, name)
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
end
