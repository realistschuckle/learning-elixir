defmodule MyList do
	def flatten(list), do: Enum.reverse(do_flatten(list, []))

	defp do_flatten([], acc), do: acc
	defp do_flatten([h | t], acc) when is_list(h), do: do_flatten(t, do_flatten(h, []) ++ acc)
	defp do_flatten([h | t], acc), do: do_flatten(t, [h | acc])
end
