defmodule Weather.CLI do
	def main(argv) do
		argv
		|> parse_args
		|> help_or_station
		|> build_url
		|> fetch_weather
		|> print_weather
	end

	def parse_args(argv) do
		parser_options = [strict: [help: :boolean], aliases: [h: :help]]
		case OptionParser.parse(argv, parser_options) do
			{[help: true], _, _} -> :help
			{[], [], []} -> :help
			{_, [station], _} -> station
			true -> :help
		end
	end

	def help_or_station(:help) do
		IO.puts("""
		Usage: weather -h | --help | <station>
		
		  -h, --help     Print this help
		  station        The station to get weather data from
		""")
		
		System.halt
	end

	def help_or_station(station) when is_binary(station) do
		station |> String.upcase
	end

	def build_url(station) do
		"http://w1.weather.gov/xml/current_obs/#{station}.xml"
	end

	def fetch_weather(url) do
		Weather.fetch(url)
	end

	def print_weather(weather) do
		IO.puts("#{weather}")
	end
end
