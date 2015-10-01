defmodule Todo.DatabaseWorker do
	use GenServer

	def start_link(db_dir, worker_id) do
		IO.puts("Starting database worker #{worker_id}.")
		GenServer.start_link(__MODULE__, db_dir, name: via_tuple(worker_id))
	end

	def store(worker_id, key, data) do
		GenServer.cast(via_tuple(worker_id), {:store, key, data})
	end

	def get(worker_id, key) do
		GenServer.call(via_tuple(worker_id), {:get, key})
	end

	def init(db_dir) do
		File.mkdir_p(db_dir)
		{:ok, db_dir}
	end

	def handle_cast({:store, key, data}, db_dir) do
		file_name(db_dir, key)
		|> File.write!(:erlang.term_to_binary(data))

		IO.puts("Stored #{data} for #{key}")
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

	defp via_tuple(worker_id) do
		{:via, :gproc, {:n, :l, {:database_worker, :here, worker_id}}}
	end
end
