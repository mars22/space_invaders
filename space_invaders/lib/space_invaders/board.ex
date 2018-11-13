defmodule SpaceInvaders.Board do
  alias __MODULE__

  # @enforce_keys [:rows, :cols]
  defstruct rows: 8,
            cols: 10,
            fields: nil,
            invaders: nil,
            player: nil,
            bullets: %{},
            invaders_fire_counter: 30

  alias SpaceInvaders.{Bullet, PlayerShip, InvaderShip, InvaderBullet}

  @doc """
  Creates a Board.
  """
  def new(invaders_list) do
    invaders =
      invaders_list
      |> List.flatten()
      |> Enum.into(%{}, fn item -> {{item.x, item.y}, item} end)

    player = %PlayerShip{x: 7, y: 6}
    fields = Map.put(invaders, {player.x, player.y}, player)
    %Board{fields: fields, invaders: invaders, player: player}
  end

  def move_down_invaders(board) do
    new_invaders =
      Enum.map(board.invaders, fn row ->
        row |> Enum.map(fn ship -> %InvaderShip{ship | x: ship.x + 1} end)
      end)

    %Board{board | invaders: new_invaders}
  end

  def move_bullets(board) do
    new_bullets =
      Enum.into(board.bullets, %{}, fn {_, bullet} ->
        nb =
          case bullet do
            %Bullet{} -> Bullet.move(bullet)
            %InvaderBullet{} -> InvaderBullet.move(bullet)
          end

        {{nb.x, nb.y}, nb}
      end)

    new_fields = Map.merge(board.invaders, new_bullets)
    %Board{board | fields: new_fields, bullets: new_bullets}
  end

  def move_player(board, dir) do
    max_y = board.cols - 1

    new_y =
      case board.player.y + dir do
        y when y < 0 -> 0
        y when y > max_y -> max_y
        y -> y
      end

    new_player = %PlayerShip{board.player | y: new_y}
    %Board{board | player: new_player}
  end

  def fire(board) do
    bullet = %Bullet{x: board.player.x - 1, y: board.player.y}
    new_bullets = Map.put(board.bullets, {bullet.x, bullet.y}, bullet)

    %Board{board | bullets: new_bullets}
  end

  defp invaders_ships_first_line(invaders) do
    group = Enum.group_by(invaders, fn {{_, col}, _} -> col end)

    max_per_group =
      Enum.map(group, fn {_, invaders} ->
        invaders
        |> Enum.filter(fn {pos, ship} -> ship.visible end)
        |> Enum.max_by(fn {pos, ship} -> pos end, fn -> nil end)
      end)

    Enum.filter(max_per_group, &(&1 != nil))
  end

  def invader_fire(board) do
    next_counter = board.invaders_fire_counter - 1

    case next_counter do
      0 ->
        {_pos, random_invader_ship} =
          invaders_ships_first_line(board.invaders)
          |> Enum.random()

        bullet = %InvaderBullet{x: random_invader_ship.x + 1, y: random_invader_ship.y}
        new_bullets = Map.put(board.bullets, {bullet.x, bullet.y}, bullet)

        %Board{board | bullets: new_bullets, invaders_fire_counter: 30}

      _ ->
        %Board{board | invaders_fire_counter: next_counter}
    end
  end

  def detect_collision(%Board{} = board) do
    invaders_positions =
      board.invaders
      |> Enum.filter(fn {_pos, inv} -> inv.visible end)
      |> Enum.map(fn {pos, _} -> pos end)
      |> MapSet.new()

    bullets_positions =
      board.bullets
      |> Enum.into(%{})
      |> Map.keys()
      |> MapSet.new()

    intersections = MapSet.intersection(invaders_positions, bullets_positions)

    intersection_with_player =
      MapSet.intersection(MapSet.new([{board.player.x, board.player.y}]), bullets_positions)

    new_invaders =
      Enum.reject(board.invaders, fn {pos, _} ->
        MapSet.subset?(MapSet.new([pos]), intersections)
      end)
      |> Enum.into(%{})

    new_bullets =
      Enum.reject(board.bullets, fn {pos, _} ->
        MapSet.subset?(MapSet.new([pos]), intersections) ||
          MapSet.subset?(MapSet.new([pos]), intersection_with_player)
      end)
      |> Enum.into(%{})

    new_bullets_pos = new_bullets |> Map.keys() |> MapSet.new()

    result = {
      %Board{board | invaders: new_invaders, bullets: new_bullets},
      MapSet.size(intersections)
    }

    case MapSet.size(intersection_with_player) > 0 do
      true ->
        {:lost_credit, result}

      false ->
        {:ok, result}
    end
  end

  def recreate_fields(board) do
    fields =
      Map.merge(board.invaders, board.bullets)
      |> Map.put({board.player.x, board.player.y}, board.player)

    %Board{board | fields: fields}
  end

  def step(board) do
    board
    # |> move_down_invaders()
    |> invader_fire()
    |> move_bullets()
    |> recreate_fields()
    |> detect_collision()
  end

  def from_level do
    read_level(8, 10) |> new()
  end

  defp read_level(rows, cols) do
    items =
      "levels/level1.txt"
      |> Path.expand(__DIR__)
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ~r{\s\s\s}, trim: true))

    create_fields(rows, cols, items)
  end

  defp create_fields(rows, cols, items) do
    for r <- 0..(rows - 2) do
      row_data = Enum.at(items, r)

      for c <- 0..(cols - 1) do
        colum_value = Enum.at(row_data || [], c)
        InvaderShip.from_data(r, c, colum_value)
      end
    end
  end

  def to_fields_mat(board) do
    for r <- 0..(board.rows - 1) do
      cf(r, board.cols, board.fields)
    end
  end

  defp cf(r, cols, items) do
    for c <- 0..(cols - 1) do
      Map.get(items, {r, c}, %{x: r, y: c, visible: false})
    end
  end
end
