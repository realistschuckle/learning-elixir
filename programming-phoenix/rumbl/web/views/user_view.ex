defmodule Rumbl.UserView do
	use Rumbl.Web, :view

	def first_name(%Rumbl.User{name: name}) do
		name
		|> String.split(" ")
		|> Enum.at(0)
	end

	def last_name(%Rumbl.User{name: name}) do
		name
		|> String.split(" ")
		|> Enum.at(1)
	end
end
