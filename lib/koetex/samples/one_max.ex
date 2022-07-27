defmodule Koetex.Samples.OneMax do
  alias Koetex.Samples.OneMax.{Provider, ChromosomesStock, LifeCycle, Fitness}

  # TODO: Koetex直下に共通化。use or behavior
  # TODO: ProviderスタートとClientスタートを別にする
  # - Clientスタートはノードコネクトが必要

  def start do
    Provider.start_link([])
    ChromosomesStock.start_link([])
    :ok
  end

  def start_as_client do
    LifeCycle.start_link([])
  end

  defdelegate share_chromosome(fitness, chromosome, phenotype \\ []), to: Provider

  def exit do
    Provider.exit()
    ChromosomesStock.exit()
    :ok
  end

  @doc """
  個体追加
  - TODO: 適応度算出用の処理だけは少なくとも知っておく必要がある（共通化する場合のこと）
  - 染色体の定義は共通（ではないと典型的な交叉ができない）
  """
  def spawn_indiv(chromosome \\ nil) do
    if Provider.connected?() do
      LifeCycle.be_born(chromosome)
    else
      :provider_process_has_not_existing
    end
  end

  @doc """
  適応度算出
  """
  def calc_fitness(factors) do
    factors
    |> Fitness.calc()
  end
end
