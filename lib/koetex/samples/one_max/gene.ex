defmodule Koetex.Samples.OneMax.Gene do
  @moduledoc """
  遺伝子
  - 必ずしも染色体ですべて同じとは限らない
  - 問題依存
  """

  def new do
    gen_binary()
  end

  @doc """
  0/1の遺伝子を作成する
  - TODO: 共通ツールへ
  """
  def gen_binary do
    Enum.random(0..1)
  end
end
