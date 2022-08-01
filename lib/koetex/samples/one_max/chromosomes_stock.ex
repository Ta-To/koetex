defmodule Koetex.Samples.OneMax.ChromosomesStock do
  use Agent

  @name __MODULE__

  @attrs %{
    size: 0,
    sum: 0,
    list: [],
    best: %{
      fitness: nil,
      chromosome: nil,
      phenotype: nil
    }
  }

  def start_link(args) do
    inits = Keyword.get(args, :inits, [])
    scale = chromosomes_stock_scale()
    Agent.start_link(fn ->
      attrs =
        inits
        |> Enum.slice(0..(scale - 1))
        |> init_attrs()
      {attrs, scale: scale}
    end, name: @name)
  end

  @doc """
  API 終了
  """
  def exit do
    if Process.whereis(@name) do
      Agent.stop(@name, :normal)
    end
  end

  @doc """
  API 個体情報の蓄積
  - ただし、蓄積されている情報と比較して可否を決定
  """
  def push({fitness, _chromosome, _phenotype} = data) do
    {size, sum} = Agent.get(@name, fn {attrs, _} -> {attrs.size, attrs.sum} end)
    result = if stockable?(fitness, size, sum), do: :accept, else: :refuse
    if result == :accept do
      stock_data(data)
      update_best_if(data)
    end
    result
  end

  @doc """
  API 個体情報の取得
  """
  def get_random_chromosome do
    Agent.get(@name, fn
      {%{list: []}, _} -> nil
      {%{list: list}, _} ->
        Enum.random(list)
        |> then(fn {fitness, chromosome, _} ->
          {fitness, chromosome}
        end)
    end)
  end

  @doc """
  ベストな個体表示
  """
  def best do
    Agent.get(@name, fn {attrs, _} -> attrs.best end)
  end

  defp init_attrs([]), do: @attrs

  defp init_attrs(inits) do
    size = Enum.count(inits)
    sum = Enum.map(inits, & elem(&1, 0)) |> Enum.sum()
    best = Enum.sort_by(inits, & elem(&1, 0), :desc) |> hd()
    %{
      size: size,
      sum: sum,
      list: inits,
      best: %{
        fitness: elem(best, 0),
        chromosome: elem(best, 1),
        phenotype: elem(best, 2)
      }
    }
  end

  defp stockable?(_fitness, 0, _sum), do: true

  defp stockable?(fitness, size, sum) do
    fitness >= (sum / size)
  end

  defp stock_data(data) do
    Agent.update(@name, fn {attrs, config} ->
      scale = Keyword.get(config, :scale)
      {oldest, rests} = List.pop_at(attrs.list, scale - 1)
      attrs
      |> Map.put(:list, [data] ++ rests)
      |> Map.update!(:size, & Enum.min([&1 + 1, scale]))
      |> Map.update!(:sum, fn sum ->
        if oldest do
          sum + elem(data, 0) - elem(oldest, 0)
        else
          sum + elem(data, 0)
        end
      end)
      |> then(& {&1, config})
    end)
  end

  defp update_best_if({fitness, chromosome, phenotype}) do
    Agent.update(@name, fn {attrs, config} ->
      attrs
      |> Map.update!(:best, fn %{fitness: c_best} = current ->
        if fitness > c_best || is_nil(c_best) do
          %{
            fitness: fitness,
            chromosome: chromosome,
            phenotype: phenotype
          }
        else
          current
        end
      end)
      |> then(& {&1, config})
    end)
  end

  defp chromosomes_stock_scale do
    Application.get_env(:koetex, Koetex)[:chromosomes_stock_scale]
  end
end
