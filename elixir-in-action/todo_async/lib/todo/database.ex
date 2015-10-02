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
		state = 0..2
		|> Stream.map(fn(i) ->
			{:ok, pid} = Todo.DatabaseWorker.start(db_dir)
			[index: i, server: pid]
		end)
		|> Enum.reduce(HashDict.new, fn(x, acc) -> Dict.put(acc, x[:index], x[:server]) end)
		{:ok, state}
	end

	def handle_cast({:store, key, data}, workers) do
		worker = get_worker(workers, key)
		Todo.DatabaseWorker.store(worker, key, data)
		{:noreply, workers}
	end

	def handle_call({:get, key}, _, workers) do
		worker = get_worker(workers, key)
		data = Todo.DatabaseWorker.get(worker, key)
		{:reply, data, workers}
	end

	defp get_worker(workers, key), do: Dict.get(workers, :erlang.phash2(key, 3))
end
