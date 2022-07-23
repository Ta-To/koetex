defmodule Koetex.Samples.OneMax.ProviderTest do
  use ExUnit.Case

  alias Koetex.Samples.OneMax.Provider
  alias Koetex.Samples.OneMax.ChromosomesStock

  def get_num_trial do
    :sys.get_state(Provider).num_trial
  end

  describe "share_chromosome/3" do
    setup do
      Provider.start_link(max_trial: 2)
      ChromosomesStock.start_link([])
      {:ok, []}
    end

    test "return response" do
      assert {:accept, _} = Provider.share_chromosome(0, [0, 0, 0], [])
    end

    test "up trial count" do
      Provider.share_chromosome(0, [0, 0, 0], [])
      assert 1 = get_num_trial()
    end

    test "exit when num of trial is over" do
      Provider.share_chromosome(0, [0, 0, 0], [])
      Provider.share_chromosome(0, [0, 0, 0], [])
      :timer.sleep(1000)
      assert is_nil(Process.whereis(Provider))
    end
  end

  describe "exit/0" do
    setup do
      Provider.start_link([])
      :net_kernel.start([:"primary@127.0.0.1"])
      :erl_boot_server.start([{127, 0, 0, 1}])
      {:ok, _node} =
        :slave.start_link(
          '127.0.0.1',
          :my_node,
          '-loader inet -hosts 127.0.0.1 -setcookie "#{:erlang.get_cookie()}"'
        )
      {:ok, []}
    end

    test "disconnect_nodes" do
      assert Enum.count(Node.list()) >= 1
      Provider.exit()
      assert [] = Node.list()
    end
  end
end

