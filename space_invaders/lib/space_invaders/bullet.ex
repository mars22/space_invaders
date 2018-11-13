defmodule SpaceInvaders.Bullet do
  alias __MODULE__

  defstruct [:x, :y, speed: 6]

  def move(bullet) do
    new_speed = bullet.speed - 1

    case new_speed do
      0 -> %Bullet{bullet | x: bullet.x - 1, speed: 6}
      _ -> %Bullet{bullet | speed: new_speed}
    end
  end
end
