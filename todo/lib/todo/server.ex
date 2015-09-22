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

	def start do
		{:ok, pid} = GenServer.start(Todo.Server, nil)
		pid
	end

	def init(_) do
		{:ok, Todo.List.new}
	end

	def handle_cast({:add_entry, new_entry}, state) do
		{:noreply, Todo.List.add_entry(state, new_entry)}
	end

	def handle_call({:entries, date}, _, state) do
		{:reply, Todo.List.entries(state, date), state}
	end
end
