defmodule AutoProcessRegistryTest do
  use ExUnit.Case
  doctest AutoProcessRegistry

  defmodule SampleModule do
    use AutoProcessRegistry

    def start_new(key) do
      Agent.start_link(fn -> key end)
    end
  end

  test "basic usage" do
    SampleModule.start_link
    assert 42 == Agent.get({:via, SampleModule, 42}, fn(key) -> key end)
    assert 666 == Agent.get({:via, SampleModule, 666}, fn(key) -> key end)
  end
end
