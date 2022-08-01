defmodule Koetex do
  @moduledoc """
  Documentation for `Koetex`.
  """

  alias Koetex.{Provider, ChromosomesStock}

  def start do
    Provider.start_link([])
    ChromosomesStock.start_link([])
    :ok
  end

  def exit do
    Provider.exit()
    ChromosomesStock.exit()
    :ok
  end
end
