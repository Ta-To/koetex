defmodule Koetex.Samples.OneMax do
  alias Koetex.Samples.OneMax.{LifeCycle, Fitness}

  def start do
    if Koetex.Provider.connected?() do
      LifeCycle.start_link([])
    else
      {:error, :there_is_no_provider_process}
    end
  end

  @doc """
  個体追加
  """
  def spawn_indiv(chromosome \\ nil) do
    LifeCycle.be_born(chromosome)
  end

  @doc """
  個体共有
  """
  defdelegate share_chromosome(fitness, chromosome, phenotype \\ []), to: Koetex.Provider

  @doc """
  適応度算出
  """
  def calc_fitness(factors) do
    factors
    |> Fitness.calc()
  end
end
