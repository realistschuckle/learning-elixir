defmodule MyList do
	def span(from, from), do: []
	def span(from, to) when from < to, do: [from | span(from + 1, to)]
end

defmodule Primes do
	def up_to(n) when n >= 2 do
		span = MyList.span(2, n + 1)
		
		filter = fn(n) ->
			Enum.all?(MyList.span(2, highest_possible_factor(n)), &(rem(n, &1) !== 0))
		end
		
		[2 | for i <- span, filter.(i), do: i]
	end

	defp highest_possible_factor(n) do
		max(3, trunc(:math.sqrt(n)) + 1)
	end																 
end
