defmodule Stack.MainSupervisor do
	use Supervisor

	def start_link(state \\ []) do
		Supervisor.start_link(__MODULE__, state)
	end

	def init(state) do
		children = [
			worker(Stack.Stash, [state]),
			supervisor(Stack.ServerSupervisor, [])
		]
		supervise(children, strategy: :one_for_one)
	end
end
