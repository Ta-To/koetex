defmodule Koetex.Samples.OneMax.Provider do
  use GenServer

  @name __MODULE__
  @global_name :ga_one_max_provider
  @max_trial 100

  alias Koetex.Samples.OneMax.ChromosomesStock

  @doc """
  API 開始
  """
  def start_link(args) do
    max_trial = Keyword.get(args, :max_trial, @max_trial)
    {:ok, pid} = GenServer.start_link(__MODULE__, %{max_trial: max_trial, num_trial: 0}, name: @name)
    :global.register_name(@global_name, pid)
    {:ok, pid}
  end

  @doc """
  API 染色体の登録/評価
  """
  def share_chromosome(fitness, chromosome, phenotype) do
    GenServer.call(
      :global.whereis_name(@global_name),
      {:share, {fitness, chromosome, phenotype}}
    )
  end

  @doc """
  API 終了
  - 参加しているプロセスにも停止通知される(`terminate`で行われる)
  """
  def exit do
    GenServer.stop(Process.whereis(@name), :normal)
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
    state = Map.update!(state, :num_trial, & &1 + 1)
    if state.num_trial >= state.max_trial do
      Process.send_after(Process.whereis(@name), :exit, 500)
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
end
