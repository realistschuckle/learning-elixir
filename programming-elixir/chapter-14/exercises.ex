defmodule Exercise3 do
	@moduledoc """
	Ask for messages only after another process
	sends one and exits.
	"""
	
	require Logger
	import :timer, only: [sleep: 1]
	
	def run do
		spawn_link(__MODULE__, :child, [self])
		sleep(500)
		receive_messages
	end

	def receive_messages do
		receive do
			msg ->
				Logger.debug(msg)
				receive_messages
		after 0 -> nil
		end
	end

	def child(pid) do
		send(pid, "Here's a message!")
	end
end

defmodule Exercise4 do
	@moduledoc """
	Ask for messages only after another process
	sends one and raises an exception.
	"""
	
	require Logger
	import :timer, only: [sleep: 1]
	
	def run do
		spawn_link(__MODULE__, :child, [self])
		sleep(500)
		receive_messages
	end

	def receive_messages do
		receive do
			msg ->
				Logger.debug(msg)
				receive_messages
		after 0 -> nil
		end
	end

	def child(pid) do
		send(pid, "Here's a message!")
		raise "I'm outta here!"
	end
end

defmodule Exercise6A do
	@moduledoc """
	Ask for messages only after another process
	sends one and exits.
	"""
	
	require Logger
	import :timer, only: [sleep: 1]
	
	def run do
		spawn_monitor(__MODULE__, :child, [self])
		sleep(500)
		receive_messages
	end

	def receive_messages do
		receive do
			msg ->
				Logger.debug(inspect(msg))
				receive_messages
		after 0 -> nil
		end
	end

	def child(pid) do
		send(pid, "Here's a message!")
	end
end

defmodule Exercise6B do
	@moduledoc """
	Ask for messages only after another process
	sends one and raises an exception.
	"""
	
	require Logger
	import :timer, only: [sleep: 1]
	
	def run do
		spawn_monitor(__MODULE__, :child, [self])
		sleep(500)
		receive_messages
	end

	def receive_messages do
		receive do
			msg ->
				Logger.debug(inspect(msg))
				receive_messages
		after 0 -> nil
		end
	end

	def child(pid) do
		send(pid, "Here's a message!")
		raise "I'm outta here!"
	end
end
