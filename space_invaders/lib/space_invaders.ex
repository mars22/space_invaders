defmodule SpaceInvaders do
  @moduledoc """
  Documentation for SpaceInvaders.
  """
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: SpaceInvaders.GameRegistry},
      SpaceInvaders.GameSupervisor
    ]

    opts = [strategy: :one_for_one, name: SpaceInvaders.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
