defmodule SpaceInvaders.Game do
  alias __MODULE__

  @enforce_keys [:board]
  defstruct board: nil, points: 0, credits: 3

  alias SpaceInvaders.{Board, Bullet, InvaderBullet, InvaderShip, PlayerShip}

  def new() do
    board = Board.from_level()
    %Game{board: board}
  end

  def move_player(%Game{board: board} = game, dir) do
    board = Board.move_player(board, dir)
    %Game{game | board: board}
  end

  def fire(%Game{board: board} = game) do
    board = Board.fire(board)
    %Game{game | board: board}
  end

  def step(%Game{board: board} = game) do
    case Board.step(board) do
      {:ok, {board, points}} ->
        %Game{game | board: board, points: game.points + points}

      {:lost_credit, {board, points}} ->
        %Game{game | board: board, points: game.points + points, credits: game.credits - 1}
    end
  end

  def to_map(game) do
    board =
      Board.to_fields_mat(game.board)
      |> List.flatten()
      |> Enum.map(fn item ->
        case item do
          %Bullet{x: x, y: y} ->
            %{x: x, y: y, type: "bullet", visible: true}

          %InvaderBullet{x: x, y: y} ->
            %{x: x, y: y, type: "invader_bullet", visible: true}

          %InvaderShip{x: x, y: y, visible: visible} ->
            %{x: x, y: y, type: "invader_ship", visible: visible}

          %PlayerShip{x: x, y: y, visible: visible} ->
            %{x: x, y: y, type: "player_ship", visible: visible}

          %{x: x, y: y, visible: visible} ->
            %{x: x, y: y, type: "field", visible: false}
        end
      end)

    %{
      board: board,
      points: game.points,
      credits: game.credits
    }
  end
end
