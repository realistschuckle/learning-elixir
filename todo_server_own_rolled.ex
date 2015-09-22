defmodule TodoServer do
	def add_entry(new_entry) do
		send(:todo_server, {:add_entry, new_entry})
	end

	def entries(date) do
		send(:todo_server, {:entries, self, date})

		receive do
			{:todo_entries, entries} -> entries
		after 5000 -> {:error, :timeout}
		end
	end
	
	def start do
		spawn(fn -> loop(TodoList.new) end)
		|> Process.register(:todo_server)
	end

	defp loop(todo_list) do
		new_todo_list = receive do
			message -> process_message(todo_list, message)
		end

		loop(new_todo_list)
	end

	defp process_message(todo_list, {:add_entry, new_entry}) do
		TodoList.add_entry(todo_list, new_entry)
	end

	defp process_message(todo_list, {:entries, caller, date}) do
		send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
		todo_list
	end
end

# 425

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
