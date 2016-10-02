defmodule AutoProcessRegistryTest do
  use ExUnit.Case
  doctest AutoProcessRegistry

  defmodule SampleModule do
    use AutoProcessRegistry

    def start_new(config, key) do
      Agent.start_link(fn -> config * key end)
    end
  end

  test "basic usage" do
    SampleModule.start_link(10)
    assert 420 == Agent.get({:via, SampleModule, 42}, fn(key) -> key end)
    assert 6660 == Agent.get({:via, SampleModule, 666}, fn(key) -> key end)
  end
end
