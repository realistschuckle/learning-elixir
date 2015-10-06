defmodule Stack.Stash do
	use GenServer

	def get do
		GenServer.call(__MODULE__, :get)
	end

	def put(value) do
		GenServer.cast(__MODULE__, {:put, value})
	end

	def start_link(state) do
		GenServer.start_link(__MODULE__, state, name: __MODULE__)
	end

	def handle_call(:get, _, state) do
		{:reply, state, state}
	end

	def handle_cast({:put, value}, _) do
		{:noreply, value}
	end
end
