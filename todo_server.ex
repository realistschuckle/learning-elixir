defmodule TodoServer do
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
		{:ok, pid} = GenServer.start(TodoServer, nil)
		pid
	end

	def init(_) do
		{:ok, TodoList.new}
	end

	def handle_cast({:add_entry, new_entry}, state) do
		{:noreply, TodoList.add_entry(state, new_entry)}
	end

	def handle_call({:entries, date}, _, state) do
		{:reply, TodoList.entries(state, date), state}
	end
end

defmodule TodoList do
	defstruct auto_id: 1, entries: HashDict.new

	def new(entries \\ []) do
		Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
	end

	def add_entry(%TodoList{entries: entries, auto_id: id} = list, entry) do
		entry = Map.put(entry, :id, id)
		new_entries = HashDict.put(entries, id, entry)
		%TodoList{list | entries: new_entries, auto_id: id + 1}
	end

	def entries(%TodoList{entries: entries}, date) do
		entries
		|> Stream.filter(fn({_, entry}) ->
			entry.date == date
		end)						 
		|> Enum.map(fn({_, entry}) -> entry end)
	end

	def update_entry(todo_list, %{} = new_entry) do
		update_entry(todo_list, new_entry.id, fn(_) -> new_entry end)
	end

	def update_entry(%TodoList{entries: entries} = list, entry_id, updater) do
		case entries[entry_id] do
			nil -> list

			old_entry ->
				old_entry_id = old_entry.id
				new_entry = %{id: ^old_entry_id} = updater.(old_entry)
				new_entries = HashDict.put(entries, new_entry.id, new_entry)
				%TodoList{list | entries: new_entries}
		end
	end

	def delete_entry(%TodoList{entries: entries} = list, entry_id) do
		new_entries = entries
		|> Stream.filter(fn({_, entry}) ->
			entry.id != entry_id
		end)
		|> Enum.map(fn({_, entry}) -> entry end)
		%TodoList{list | entries: new_entries}
	end
end
