defmodule Koetex.Provider do
  use GenServer

  @name __MODULE__

  alias Koetex.ChromosomesStock

  @doc """
  API 開始
  """
  def start_link(_args) do
    {:ok, pid} = GenServer.start_link(
      __MODULE__,
      %{sharing_count: 0, max_sharing_count: max_sharing_count()},
      name: @name
    )
    :global.register_name(global_name(), pid)
    {:ok, pid}
  end

  @doc """
  API 染色体の登録/評価
  """
  def share_chromosome(fitness, chromosome, phenotype) do
    try do
      GenServer.call(
        :global.whereis_name(global_name()),
        {:share, {fitness, chromosome, phenotype}}
      )
    catch
      :exit, {:noproc, _} -> {:error, "Server Error"}
    end
  end

  @doc """
  API 終了
  - 参加しているプロセスにも停止通知される(`terminate`で行われる)
  """
  def exit do
    if Process.whereis(@name) do
      GenServer.stop(@name, :normal)
    end
  end

  @doc """
  API 接続確認
  """
  def connected? do
    :global.whereis_name(global_name())
    |> case do
      :undefined -> false
      _ -> true
    end
  end

  @impl GenServer
  def init(args) do
    {:ok, args}
  end

  @impl GenServer
  def terminate(_reason, _state) do
    disconnect_nodes()
    :normal
  end

  @impl GenServer
  def handle_call({:share, data}, _from, state) do
    response = ChromosomesStock.push(data)
    chromosome = ChromosomesStock.get_random_chromosome()
    state = Map.update!(state, :sharing_count, & &1 + 1)
    if state.sharing_count >= state.max_sharing_count do
      IO.inspect(ChromosomesStock.best, label: "SharingCountOver")
      Process.send_after(Process.whereis(@name), :exit, 10)
    end
    {:reply, {response, chromosome}, state}
  end

  @impl GenServer
  def handle_info(:exit, state) do
    {:stop, :normal, state}
  end

  defp disconnect_nodes do
    Node.list(:connected)
    |> Enum.each(& Node.disconnect/1)
  end

  defp global_name do
    Application.get_env(:koetex, Koetex)[:provider_global_name]
    |> String.to_atom()
  end

  defp max_sharing_count do
    Application.get_env(:koetex, Koetex)[:max_sharing_count]
  end
end
