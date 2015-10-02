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

defmodule TodoList.CsvImporter do
	def import!(path) do
		File.stream!(path)
		|> Stream.map(&String.replace(&1, "\n", ""))
		|> Stream.map(fn(line) ->
			[date, activity] = String.split(line, ",")
			[year, month, day] = String.split(date, "/")
			year = String.to_integer(year)
			month = String.to_integer(month)
			day = String.to_integer(day)
			date = {year, month, day}
			%{date: date, title: activity}
		end)
		|> TodoList.new
	end
end

									
