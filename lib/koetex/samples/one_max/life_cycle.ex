defmodule Koetex.Samples.OneMax.LifeCycle do
  use GenServer
  alias Koetex.Samples.OneMax.{Chromosome, Indiv}

  @name __MODULE__
  # 個体の生存回数: 指定回数の再生産フェーズ後に削除
  @max_survival_count 10
  # 生存個体の休眠スケール: 指定数程度の個体が休眠中に評価されると考えられる
  @break_time_scale 10

  @doc """
  API 開始
  """
  def start_link(args) do
    max_survival_count = Keyword.get(args, :max_survival_count, @max_survival_count)
    break_time_scale = Keyword.get(args, :break_time_scale, @break_time_scale)
    GenServer.start_link(__MODULE__, %{max_survival_count: max_survival_count, break_time_scale: break_time_scale}, name: @name)
  end

  def be_born(chromosome \\ nil) do
    chromosome = chromosome || Chromosome.new()
    {:ok, pid} = Indiv.start(chromosome)
    Indiv.grow(pid)
  end

  def reproduce(pid_indiv) do
    GenServer.cast(@name, {:reproduce, pid_indiv})
  end

  def break_time(pid_indiv) do
    GenServer.cast(@name, {:break_time, pid_indiv})
  end

  def relay(pid_indiv, chromosome) do
    GenServer.cast(@name, {:relay, pid_indiv, chromosome})
  end

  def gone(pid_indiv) do
    GenServer.cast(@name, {:gone, pid_indiv})
  end

  @impl GenServer
  def init(args) do
    {:ok, args}
  end

  @impl GenServer
  def handle_cast({:reproduce, pid_indiv}, config) do
    Indiv.reproduce(pid_indiv)
    {:noreply, config}
  end

  @impl GenServer
  def handle_cast({:break_time, pid_indiv}, config) do
    if Indiv.survival_count(pid_indiv) > config.max_survival_count do
      # 別のプロセスとして新しく再生産
      # （意味合い的には老衰だろうか）
      Agent.stop(pid_indiv, :normal)
      be_born()
    else
      Indiv.taken_to_grow(pid_indiv)
      |> then(& :timer.sleep(&1 * config.break_time_scale))
      Indiv.reproduce(pid_indiv)
    end
    {:noreply, config}
  end

  @impl GenServer
  def handle_cast({:relay, pid_indiv, child_chromosome}, config) do
    Agent.stop(pid_indiv, :normal)
    be_born(child_chromosome)
    {:noreply, config}
  end

  @impl GenServer
  def handle_cast({:gone, pid_indiv}, config) do
    Agent.stop(pid_indiv, :normal)
    {:noreply, config}
  end
end
