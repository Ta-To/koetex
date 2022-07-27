defmodule Koetex.Samples.OneMax.Fitness do
  @doc """
  適合度を返す
  """
  def calc(factors) do
    factors
    |> Enum.sum()
  end
end
