defmodule Issues.GithubIssues do
	@user_agent [{"User-agent", "Programming Elixir exercise by curtis@schlak.com"}]
	@github_url Application.get_env(:issues, :github_url)

	def fetch(user, project) do
		{user, project}
		|> issues_url
		|> HTTPoison.get(@user_agent)
		|> handle_response
	end

	defp issues_url({user, project}) do
		"#{@github_url}/repos/#{user}/#{project}/issues"
	end

	defp handle_response({:ok, response}) do
		{:ok, :jsx.decode(response.body)}
	end
	
	defp handle_response({:error, error}) do
		{:error, :jsx.decode(error.body)}
	end
end
