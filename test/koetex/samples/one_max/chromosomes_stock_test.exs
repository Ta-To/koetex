defmodule Koetex.Samples.OneMax.ChromosomesStockTest do
  use ExUnit.Case

  alias Koetex.Samples.OneMax.ChromosomesStock

  defp get_attrs do
    :sys.get_state(ChromosomesStock) |> elem(0)
  end

  describe "start_link/1" do
    test "initialize" do
      ChromosomesStock.start_link([])
      assert %{list: []} = get_attrs()
    end

    test "initialize with args" do
      ChromosomesStock.start_link(
        inits: [
          {6, [1, 1, 1], [2, 2, 2]},
          {8, [2, 1, 1], [4, 2, 2]}
        ]
      )
      assert %{
        size: 2,
        sum: 14,
        list: [
          {6, [1, 1, 1], [2, 2, 2]},
          {8, [2, 1, 1], [4, 2, 2]}
        ],
        best: %{
          fitness: 8,
          chromosome: [2, 1, 1],
          phenotype: [4, 2, 2]
        }
      } = get_attrs()
    end
  end

  describe "push/1" do
    setup c do
      case c[:inits] do
        :empty ->
          ChromosomesStock.start_link([])
        :present ->
          ChromosomesStock.start_link(
            inits: [
              {6, [1, 1, 1], [2, 2, 2]},
              {8, [2, 1, 1], [4, 2, 2]}
            ]
          )
        :full ->
          ChromosomesStock.start_link(
            inits: [
              {6, [1, 1, 1], [2, 2, 2]},
              {8, [2, 1, 1], [4, 2, 2]}
            ],
            scale: 2
          )
      end
      {:ok, []}
    end

    @tag inits: :empty
    test "stock when stock is empty" do
      :accept = ChromosomesStock.push({0, [0, 0, 0], [0, 0, 0]})
      assert %{
        size: 1,
        sum: 0,
        list: [{0, [0, 0, 0], [0, 0, 0]}],
        best: %{fitness: 0, chromosome: [0, 0, 0], phenotype: [0, 0, 0]}
      } = get_attrs()
    end

    @tag inits: :present
    test "stock new best one" do
      :accept = ChromosomesStock.push({10, [2, 2, 1], [4, 4, 2]})
      assert %{
        size: 3,
        sum: 24,
        list: [
          {10, [2, 2, 1], [4, 4, 2]},
          {6, [1, 1, 1], [2, 2, 2]},
          {8, [2, 1, 1], [4, 2, 2]}
        ],
        best: %{fitness: 10, chromosome: [2, 2, 1], phenotype: [4, 4, 2]}
      } = get_attrs()
    end

    @tag inits: :present
    test "stock new NOT best one" do
      :accept = ChromosomesStock.push({8, [1, 2, 1], [2, 4, 2]})
      assert %{
        size: 3,
        sum: 22,
        list: [
          {8, [1, 2, 1], [2, 4, 2]},
          {6, [1, 1, 1], [2, 2, 2]},
          {8, [2, 1, 1], [4, 2, 2]}
        ],
        best: %{fitness: 8, chromosome: [2, 1, 1], phenotype: [4, 2, 2]}
      } = get_attrs()
    end

    @tag inits: :present
    test "refuse to stock" do
      :refuse = ChromosomesStock.push({6, [1, 1, 1], [2, 2, 2]})
    end

    @tag inits: :full
    test "stock and drop oldest when stock is fill" do
      :accept = ChromosomesStock.push({8, [2, 1, 1], [4, 2, 2]})
      assert %{
        size: 2,
        sum: 14,
        list: [
          {8, [2, 1, 1], [4, 2, 2]},
          {6, [1, 1, 1], [2, 2, 2]}
        ],
        best: %{fitness: 8, chromosome: [2, 1, 1], phenotype: [4, 2, 2]}
      } = get_attrs()
    end
  end

  describe "get_random_chromosome/0" do
    setup c do
      case c[:inits] do
        :empty ->
          ChromosomesStock.start_link([])
        :present ->
          ChromosomesStock.start_link(
            inits: [
              {6, [1, 1, 1], [2, 2, 2]},
              {8, [2, 1, 1], [4, 2, 2]}
            ]
          )
      end
      {:ok, []}
    end

    @tag inits: :present
    test "return chromosome for improvement" do
      # Seed to decide random function's output in the agent process
      Agent.get(ChromosomesStock, fn _ -> :rand.seed(:exsplus, {101, 102, 103}) end)
      {fitness, chromosome} = ChromosomesStock.get_random_chromosome()
      assert 6 = fitness
      assert [1, 1, 1] = chromosome
    end

    @tag inits: :empty
    test "return nil when stock is empty" do
      assert is_nil(ChromosomesStock.get_random_chromosome())
    end
  end
end
