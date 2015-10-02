defmodule MyList do
	def max([]), do: 0
	def max([head | []]), do: head
	def max([head | [next | tail]]) when head > next, do: max([head | tail])
	def max([_ | tail]), do: max(tail)
end

	
