defmodule ExHannibal.LinkController do
  use ExHannibal.Web, :controller

  def index(conn, %{"api_key" => key, "package_hash" => hash}) do
    render(conn, "ets_state.json", %{})
  end

  def get_new_packages(conn, %{"api_key" => key}) do
    package_list = :ets.match_object(:packages, {key, :"$1", :"$2", "new"})
    data = package_list_helper(package_list, [])
    conn |> json(data)
  end

  def one_package(conn, %{"api_key" => key, "package_hash" => hash}) do
    package_list = :ets.match_object(:packages, {key, :"$1", :"$2", :new})
    data = package_list_helper(package_list, [])
    conn |> json(List.first(data))
  end

  def update_packagestate(conn, %{"api_key" => api_key, "package_hash" => hash, "data" => data}) do
    %{"package_name" => package_name, "hash" => hash, "old_state" => old_state, "new_state" => new_state} = data
    ## ATTENTION RACE CONDITION
    one = :ets.insert(:packages, {api_key, package_name, hash, new_state})
    two = :ets.delete_object(:packages, {api_key, package_name, hash, old_state})
    IO.inspect one
    IO.inspect two
    conn |> json(:ok)
  end

  def update_linkstate(conn, %{"api_key" => api_key , "_json" => data}) do
      %{"package_name" => package_name, "hash" => hash, "link" => link, "old_state" => state, "new_state" => new_state}  = data
      ## ATTENTION RACE CONDITION
      :ets.insert_new(:links, {package_name, hash, link, new_state})
      :ets.delete_object(:links, {package_name, hash, link, state})
  end

  def add_package(conn, %{"api_key" => key, "_json" => data}) do
    IO.inspect data
    [data] = data
    :ets.insert(:packages, {key, Map.get(data, "name"), Map.get(data, "name"), "new"})
    add_links_to_package( Map.get(data, "links"), Map.get(data, "name"))
    conn |> json :ok
  end



  #+#+#+

  defp package_list_helper([head| tail], result) do
    {key, hash, package_name, state} = head
    links = :ets.match_object(:links, {package_name, :"$1",:"$2",:"$3"})
    links = link_list_helper(links, [])
    result = [%{key: key, hash: hash, name: package_name, links: links, state: state}|result]
    package_list_helper(tail, result)
  end

  defp package_list_helper([], state) do
    state
  end


  defp link_list_helper([head | tail], result) do
    {package, hash, link, state} = head
    result = [%{hash: hash, link: link, state: state}|result]
    link_list_helper(tail, result)
  end

  defp link_list_helper([], state) do
    state
  end

  defp add_links_to_package([head | tail], package_name) do
  %{"hash" => hash, "link" => link, "state" => state}  = head
    add_links_to_package(tail, package_name)
    :ets.insert(:links, {package_name, hash, link, state})
  end

  defp add_links_to_package([], package_name) do
  end
end
