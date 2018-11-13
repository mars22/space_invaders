defmodule SpaceInvaders.InvaderBullet do
  alias __MODULE__

  @enforce_keys [:x, :y]
  defstruct [:x, :y, speed: 20]

  def move(bullet) do
    new_speed = bullet.speed - 1

    case new_speed do
      0 -> %InvaderBullet{bullet | x: bullet.x + 1, speed: 20}
      _ -> %InvaderBullet{bullet | speed: new_speed}
    end
  end
end
