defmodule SpaceInvaders.InvaderShip do
  alias __MODULE__

  @enforce_keys [:x, :y]
  defstruct [:x, :y, :height, :width, visible: true]

  @doc """
  Creates a invader ship.
  """
  def from_data(x, y, value) do
    case value do
      "x" -> %InvaderShip{x: x, y: y}
      _ -> %InvaderShip{x: x, y: y, visible: false}
    end
  end
end
