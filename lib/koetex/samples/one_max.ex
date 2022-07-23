defmodule Koetex.Samples.OneMax do
  alias Koetex.Samples.OneMax.{Provider, ChromosomesStock}

  def start do
    Provider.start_link([])
    ChromosomesStock.start_link([])
  end

  defdelegate share_chromosome(fitness, chromosome, phenotype \\ []), to: Provider

  defdelegate exit, to: Provider
end
