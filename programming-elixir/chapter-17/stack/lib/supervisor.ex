defmodule Stack.ServerSupervisor do
	use Supervisor

	def start_link(state \\ []) do
		IO.puts("Starting Stack.Supervisor with #{state}")
		Supervisor.start_link(__MODULE__, state)
	end

	def init(state) do
		children = [
			worker(Stack.Server, [state])
		]
		supervise(children, strategy: :one_for_one)
	end
end
