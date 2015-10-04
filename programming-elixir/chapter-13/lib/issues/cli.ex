defmodule Issues.CLI do
	@default_count 4
	
	@moduledoc """
	Handle the command line parsing and the dispatch to
	the various functions that end up generating a
	table of the last _n_ issues in a github project
	"""

	def run(argv) do
		argv
		|> parse_args
		|> process
	end

	@doc """
	`argv` can be -h or --help, which returns :help.
	
	Otherwise, it is a github user name, project name, and
	(optionally) the number of entries to format.
	
	Return a tuple of `{user, project, count}`, or `:help`
	if help was given.
	"""
	def parse_args(argv) do
		parse = OptionParser.parse(argv, strict: [help: :boolean], aliases: [h: :help])
		case parse do
			{[help: true], _, _} -> :help
			{_, [user, project, count], _} -> {user, project, String.to_integer(count)}
			{_, [user, project], _} -> {user, project, @default_count}
			true -> :help
		end
	end

	def process(:help) do
		IO.puts("""
		usage:  issues <user> <project> [ count | #{@default_count} ]
		""")
		System.halt(0)
	end

	def process({user, project, count}) do
		Issues.GithubIssues.fetch(user, project)
		|> decode_response
		|> convert_to_list_of_hashdicts
		|> sort_into_ascending_order
		|> Enum.take(count)
		|> display
	end

	def convert_to_list_of_hashdicts(list) do
		list
		|> Enum.map(&Enum.into(&1, HashDict.new))
	end

	def decode_response({:ok, body}), do: body
	def decode_response({:error, error}) do
		{_, message} = List.keyfind(error, "message", 0)
		IO.puts("Error fetching from GitHub: #{message}")
		System.halt(2)
	end

	def display(list) do
		number_width = max(3, list |> longest("number"))
		date_width = list |> longest("created_at")
		title_width = list |> longest("title")
		adjusted_title_width = min(72 - number_width - date_width, title_width)

		write_headers(number_width, date_width)
		write_headers_border(number_width, date_width, adjusted_title_width)

		list
		|> Enum.each(&(write_issue(&1, number_width, date_width, adjusted_title_width)))
	end

	def longest(issues, field) do
		issues
		|> Enum.reduce(0, fn
			(issue, acc) ->
				len = issue[field] |> to_string |> String.length
				max(acc, len)
		end)
	end

	def sort_into_ascending_order(list) do
		list
		|> Enum.sort(fn(i1, i2) -> i1["created_at"] <= i2["created_at"] end)
	end

	def write_headers(number_width, date_width) do
		:io.fwrite(' ~-#{number_width - 1}s | ~-#{date_width}s | title~n', ['#', 'created_at'])
	end

	def write_headers_border(number_width, date_width, title_width) do
		:io.fwrite('~#{number_width + 1}..-s+~-#{date_width + 2}..-s+~-#{title_width + 2}..-s~n', ['-', '-', '-'])
	end

	def write_issue(issue, number_width, date_width, title_width) do
		values = [
			issue["number"],
			issue["created_at"],
			String.slice(issue["title"], 0, title_width)
		]
		:io.fwrite('~-#{number_width}B | ~-#{date_width}s | ~s~n', values)
	end
end
