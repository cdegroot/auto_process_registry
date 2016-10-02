[![Build Status](https://travis-ci.org/cdegroot/auto_process_registry.svg?branch=master)](https://travis-ci.org/cdegroot/auto_process_registry)

# AutoProcessRegistry

This small module is a process registry that can automatically start new
processes if a process for a key doesn't exist.

See the module docs for more info. There's a single unit test at the
moment that shows how to use it.

## Usage


  1. Add `auto_process_registry` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:auto_process_registry, "~> 0.1.0"}]
    end
    ```

  2. Read the [documentation](https://hexdocs.pm/auto_process_registry/) on how to use
  it.

## License

Apache 2.0

## Contributing

Github standard process.

## Acknowledgements

A lot of inspration--and, frankly, code--comes from [this article](https://medium.com/@StevenLeiva1/elixir-process-registries-a27f813d94e3#.x3wx7nfck) by Steven Leiva.
