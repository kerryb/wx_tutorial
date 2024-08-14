defmodule WxTutorialTest do
  use ExUnit.Case
  doctest WxTutorial

  test "greets the world" do
    assert WxTutorial.hello() == :world
  end
end
