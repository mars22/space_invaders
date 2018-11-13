defmodule SpaceInvaders.Player do
  alias __MODULE__

  @enforce_keys [:name, :color]
  defstruct [:name, :color]

  @doc """
  Creates a player with the given `name` and `color`.
  """
  def new(name, color) do
    %Player{name: name, color: color}
  end
end
