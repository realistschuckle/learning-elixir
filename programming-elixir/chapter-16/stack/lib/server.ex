defmodule Stack.Server do
	use GenServer

	def pop do
		GenServer.call(__MODULE__, :pop)
	end

	def push(value) do
		GenServer.cast(__MODULE__, {:push, value})
	end

	def start_link(state \\ []) do
		GenServer.start_link(__MODULE__, state, name: __MODULE__)
	end

	def handle_call(:pop, _, [head | tail]) do
		{:reply, head, tail}
	end

	def handle_cast({:push, value}, list) do
		{:noreply, [value | list]}
	end
end
