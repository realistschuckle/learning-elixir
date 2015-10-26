defmodule Rumbl.User do
	use Rumbl.Web, :model

	alias Ecto.Changeset, as: CS

	schema "users" do
		field :name, :string
		field :username, :string
		field :password, :string, virtual: true
		field :password_hash, :string

		timestamps
	end

	def changeset(model, params \\ :empty) do
		model
		|> cast(params, ~w(name username), [])
		|> validate_length(:username, min: 1, max: 20)
	end

	def registration_changeset(model, params \\ :empty) do
		model
		|> changeset(params)
		|> cast(params, ~w(password), [])
		|> validate_length(:password, min: 6, max: 100)
		|> hash_password
	end

	defp hash_password(%CS{valid?: true, changes: %{password: pass}} = changeset) do
		put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
	end

	defp hash_password(changeset),
		do: changeset
end
