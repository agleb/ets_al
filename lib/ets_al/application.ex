defmodule EtsAl.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      %{id: EtsAl.Keeper, start: {EtsAl.Keeper, :start_link, [[]]}},
    ]

    opts = [strategy: :one_for_one, name: EtsAl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
