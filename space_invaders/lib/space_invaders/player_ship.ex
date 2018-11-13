defmodule SpaceInvaders.PlayerShip do
  @enforce_keys [:x, :y]
  defstruct [:x, :y, visible: true]
end
