# EtsAl

ETS abstraction layer and assets keeper.

## Installation

```elixir
def deps do
  [
    {:ets_al, "~> 0.1.2"}
  ]
end
```

## Usage

Start the EtsAl.Keeper under your supervision tree in the right place to keep your ETS assets.

```elixir
require EtsAl.Keeper
```

Alternatively you can use EtsAl.Behaviour in your module as a boilerplate for your ETS operations engine.

## TODO

Add examples to the docs.
Expand docs.

## License

MIT.
