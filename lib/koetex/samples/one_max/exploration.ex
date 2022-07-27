defmodule Koetex.Samples.OneMax.Exploration do
  @moduledoc """
  問題解決のための探索処理（交叉/突然変異）を扱う
  """

  def cross(chromosome_1, nil), do: [chromosome_1]

  def cross(chromosome_1, chromosome_2) do
    cx_point = :rand.uniform(Enum.count(chromosome_1))
    {front_1, back_1} = Enum.split(chromosome_1, cx_point)
    {front_2, back_2} = Enum.split(chromosome_2, cx_point)
    [front_1 ++ back_2, front_2 ++ back_1]
  end

  def mutate(chromosome_or_gene)

  def mutate(chromosome) do
    if :rand.uniform() < 0.05,
      do: Enum.shuffle(chromosome),
      else: chromosome
  end
end
