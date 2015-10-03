defmodule MyString do
	def capitalize_sentences(binary) do
		binary
		|> String.split(". ", trim: true)
		|> Enum.map(&String.capitalize/1)
		|> Enum.join(". ")
		|> Kernel.<>(". ")
	end
	
	def center(binaries) do
		binaries
		|> Enum.reduce(0, &str_max/2)
		|> pad(binaries, [])
		|> Enum.reverse
		|> Enum.each(&IO.puts/1)
	end

	defp str_max(x, len), do: max(len, String.length(x))

	defp pad(_, [], acc), do: acc
	defp pad(width, [h | t], acc) do
		padded = String.duplicate(" ", div((width - String.length(h)), 2)) <> h
		pad(width, t, [padded | acc])
	end
end

		
