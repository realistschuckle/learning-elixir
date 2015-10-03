defmodule MyString do
	@printable_range ?\s..?~
	
	def printable?(char_list) do
		Enum.all?(char_list, fn(c) -> c in @printable_range end)
	end

	def anagram?(char_list1, char_list2) do
		length(char_list1) === length(char_list2)
		and length(char_list1 -- char_list2) === 0
	end
end
