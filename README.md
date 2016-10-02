# AutoProcessRegistry

This small module is a process registry that can automatically start new
processes if a process for a key doesn't exist.

See the module docs for more info. There's a single unit test at the
moment that shows how to use it.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `auto_process_registry` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:auto_process_registry, "~> 0.1.0"}]
    end
    ```

  2. Ensure `auto_process_registry` is started before your application:

    ```elixir
    def application do
      [applications: [:auto_process_registry]]
    end
    ```

