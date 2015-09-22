defmodule ServerProcess do
	def call(server_pid, request) do
		send(server_pid, {:call, request, self})
		receive do
			{:response, response} -> response
		end
	end

	def cast(server_pid, request) do
		send(server_pid, {:cast, request})
	end
	
	def start(callback_module) do
		spawn(fn ->
			initial_state = callback_module.init
			loop(callback_module, initial_state)
		end)
	end

	defp loop(callback_module, current_state) do
		receive do
			{:call, request, caller} ->
				{response, new_state} = callback_module.handle_call(request, current_state)
				send(caller, {:response, response})

				loop(callback_module, new_state)

			{:cast, request} ->
				new_state = callback_module.handle_cast(request, current_state)
				
				loop(callback_module, new_state)
		end
	end
end


defmodule TodoServer do
	def add_entry(new_entry) do
		ServerProcess.cast(:todo_server, {:add_entry, new_entry})
	end

	def entries(date) do
		ServerProcess.call(:todo_server, {:entries, date})
	end

	def init do
		TodoList.new
	end

	def start do
		ServerProcess.start(TodoServer)
		|> Process.register(:todo_server)
	end

	def handle_cast({:add_entry, new_entry}, todo_list) do
		TodoList.add_entry(todo_list, new_entry)
	end

	def handle_call({:entries, date}, todo_list) do
		{TodoList.entries(todo_list, date), todo_list}
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
