defmodule MyString do
	@printable_range ?\s..?~
	
	def printable?(char_list) do
		Enum.all?(char_list, fn(c) -> c in @printable_range end)
	end
end
