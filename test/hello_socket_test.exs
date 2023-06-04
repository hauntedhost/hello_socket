defmodule HelloSocketTest do
  use ExUnit.Case
  doctest HelloSocket

  test "greets the world" do
    assert HelloSocket.hello() == :world
  end
end
