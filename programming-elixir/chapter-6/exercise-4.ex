defmodule Recursive do
	def sum(1), do: 1
	def sum(n) when n > 1, do: n + sum(n - 1)
end
