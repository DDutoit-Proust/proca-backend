defmodule Proca.Contact.Input do
  alias Ecto.Changeset
  alias Proca.{ActionPage, Contact}

  @doc """
  Accepts attributes and returns a (virtual) validated data changeset
  """
  @callback from_input(map()) :: Changeset.t

  @doc "Given params with name or split name, recompute others"
  def normalize_names_attr(attr = %{first_name: _, name: _}) do
    attr
  end

  def normalize_names_attr(attr = %{first_name: fst, last_name: lst}) do
    attr
    |> Map.put(:name, String.trim "#{fst} #{lst}")
  end

  def normalize_names_attr(attr = %{name: n}) do
    attr
    |> Map.put(:first_name, hd(String.split(n, " ")))
    |> Map.put(:last_name, tl(String.split(n, " ")) |> Enum.join(" "))
  end

  def normalize_names_attr(attr) do
    attr
  end

  @email_format Regex.compile! "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"
  def validate_email(chst, field) do
    chst
    |> Changeset.validate_format(field, @email_format)
  end

  @phone_format ~r{[0-9+ -]+}
  def validate_phone(chst, field) do
    chst
    |> Changeset.validate_format(field, @phone_format)
  end
end