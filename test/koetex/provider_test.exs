defmodule Koetex.ProviderTest do
  use ExUnit.Case

  alias Koetex.Provider
  alias Koetex.ChromosomesStock

  def get_sharing_count do
    :sys.get_state(Provider).sharing_count
  end

  describe "share_chromosome/3" do
    setup do
      prev_env = Application.get_env(:koetex, Koetex)
      Application.put_env(:koetex, Koetex, Keyword.put(prev_env, :max_sharing_count, 2))
      on_exit(fn -> Application.put_env(:koetex, Koetex, prev_env) end)

      Provider.start_link([])
      ChromosomesStock.start_link([])
      {:ok, []}
    end

    test "return response" do
      assert {:accept, _} = Provider.share_chromosome(0, [0, 0, 0], [])
    end

    test "up sharing count" do
      Provider.share_chromosome(0, [0, 0, 0], [])
      assert 1 = get_sharing_count()
    end

    test "exit when num of sharing is over" do
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

