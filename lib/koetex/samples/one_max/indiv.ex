defmodule Koetex.Samples.OneMax.Indiv do
  @moduledoc """
  個体
  - 染色体 chromosome
  - 成長時間 taken_to_grow [sec]
  - 生存期間 survival_count
  - 表現型 phenotype
  - 適応度 fitness
  """

  use Agent
  alias Koetex.Samples.OneMax.{Chromosome, Exploration, LifeCycle}

  @doc """
  API 追加
  """
  def start(chromosome) do
    Agent.start_link(fn -> new_indiv(chromosome) end, name: unique_indiv_name())
  end

  defp new_indiv(chromosome) do
    %{
      chromosome: chromosome,
      taken_to_grow: nil,
      survival_count: 0,
      phenotype: nil,
      fitness: nil
    }
  end

  @doc """
  API 成長処理
  - 重い処理を考慮して非同期で行うためにcastする
  """
  def grow(pid) do
    Agent.cast(pid, __MODULE__, :_grow, [])
  end

  @doc """
  API 交叉など処理
  """
  def reproduce(pid) do
    Agent.cast(pid, __MODULE__, :_reproduce, [])
  end

  def survival_count(pid), do: Agent.get(pid, & &1.survival_count)

  def taken_to_grow(pid), do: Agent.get(pid, & &1.taken_to_grow)

  def _grow(state) do
    {micro_sec, {phenotype, fitness}} = :timer.tc(fn ->
      phenotype = Chromosome.to_phenotype(state.chromosome)
      fitness = Koetex.Samples.OneMax.calc_fitness(phenotype)
      {phenotype, fitness}
    end)
    msec = div(micro_sec, 1000)
    LifeCycle.reproduce(self())
    Map.merge(state, %{
      taken_to_grow: msec,
      survival_count: 0,
      phenotype: phenotype,
      fitness: fitness
    })
  end

  def _reproduce(state) do
    Koetex.Samples.OneMax.share_chromosome(
      state.fitness,
      state.chromosome,
      state.phenotype
    )
    |> then(fn item -> IO.inspect(item); item end)
    |> case do
      {:error, _} ->
        LifeCycle.gone(self())
      {:refuse, {_fitness, shared_chromosome}} ->
        # 世代交代 交叉/突然変異後に更新
        new_next_chromosome(state.chromosome, shared_chromosome)
        |> then(& LifeCycle.relay(self(), &1))
      {:accept, _} ->
        # 変化なしで生存
        LifeCycle.break_time(self())
    end
    Map.update!(state, :survival_count, & &1 + 1)
  end

  defp new_next_chromosome(chromosome_1, chromosome_2) do
    Exploration.cross(chromosome_1, chromosome_2)
    |> Enum.random()
    |> Exploration.mutate()
  end

  defp unique_indiv_name, do: :"indiv_#{System.unique_integer()}"
end
