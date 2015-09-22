defmodule Todo.Database do
	use GenServer

	def start(db_dir) do
		GenServer.start(__MODULE__, db_dir, name: :database_server)
	end

	def store(key, data) do
		GenServer.cast(:database_server, {:store, key, data})
	end

	def get(key) do
		GenServer.call(:database_server, {:get, key})
	end

	def init(db_dir) do
		File.mkdir_p(db_dir)
		{:ok, db_dir}
	end

	def handle_cast({:store, key, data}, db_dir) do
		file_name(db_dir, key)
		|> File.write!(:erlang.term_to_binary(data))

		{:noreply, db_dir}
	end

	def handle_call({:get, key}, _, db_dir) do
		data = case File.read(file_name(db_dir, key)) do
						 {:ok, contents} -> :erlang.binary_to_term(contents)
						 _ -> nil
					 end

		{:reply, data, db_dir}
	end

	defp file_name(db_dir, key), do: "#{db_dir}/#{key}"
end
