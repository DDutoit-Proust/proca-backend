defmodule ProcaWeb.Resolvers.ActionPage do
  @moduledoc """
  Resolvers for action page related mutations
  """
  import Ecto.Query
  alias Proca.ActionPage
  alias Proca.Repo
  alias ProcaWeb.Helper
  alias Proca.Server.Notify


  defp by_id(query, id) do
    query |> where([x], x.id == ^id)
  end

  defp by_name(query, name) do
    query |> where([x], x.name == ^name)
  end

  defp find_one(criteria) do
    query =
      from(p in Proca.ActionPage, preload: [[campaign: :org], :org], limit: 1)
      |> criteria.()

    case Proca.Repo.one(query) do
      nil ->
        {:error,
         %{
           message: "Action page not found",
           extensions: %{code: "not_found"}
         }}

      ap ->
        {:ok, ap |> Proca.ActionPage.stringify_config()}
    end
  end

  def find(_, %{id: id}, _) do
    find_one(&by_id(&1, id))
  end

  def find(_, %{name: name}, _) do
    find_one(&by_name(&1, ActionPage.remove_schema_from_name(name)))
  end

  # XXX legacy
  def find(_, %{url: url}, _) do
    find_one(&by_name(&1, ActionPage.remove_schema_from_name(url)))
  end

  def find(_, %{}, _) do
    {:error, "You must pass either id or name to query for ActionPage"}
  end

  def campaign(ap, %{}, _) do
    {
      :ok,
      Repo.preload(ap, campaign: :org).campaign
    }
  end

  def update(_, attrs = %{id: id}, %{context: %{user: user}}) do
    case Repo.get_by(ActionPage, id: id)
         |> Helper.can_manage?(user, fn ap ->
           ap
           |> ActionPage.changeset(attrs)
           |> Repo.update()
         end) do
      {:error, chset = %Ecto.Changeset{}} ->
        {:error, Helper.format_errors(chset)}

      {:error, msg} ->
        {:error, msg}

      {:ok, ap} ->
        Notify.action_page_updated(ap)
        {:ok, ap}
    end
  end
end
