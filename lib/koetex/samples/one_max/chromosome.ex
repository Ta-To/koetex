defmodule Koetex.Samples.OneMax.Chromosome do
  @moduledoc """
  染色体
  """

  alias Koetex.Samples.OneMax.Gene

  @size 100

  def new do
    (1..@size)
    |> Enum.map(fn _ -> Gene.new() end)
  end

  @doc """
  染色体から評価に必要なものを生成する
  - 例えば、染色体=学習パラメータであればモデル構築処理を行う
  """
  def to_phenotype(chromosome) do
    chromosome
  end
end
