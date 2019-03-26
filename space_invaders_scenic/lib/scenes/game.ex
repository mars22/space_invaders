defmodule SpaceInvadersScenic.Scene.Game do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives
  import Scenic.Components

  alias SpaceInvaders.{GameServer, GameSupervisor}

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(initial, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {width, _}}} =
      opts[:viewport]
      |> ViewPort.info()

    game_name = Keyword.get(initial, :name, "the_game")
    IO.inspect(width)

    case GameServer.game_pid(game_name) do
      pid when is_pid(pid) -> GameServer.change_parent_pid(game_name, self())
      _ -> GameSupervisor.start_game(game_name, self())
    end

    graph =
      Graph.build(font: :roboto, font_size: 24)
      |> text("Score: ", id: :score, translate: {20, 60})
      |> text("Credits: ", translate: {width - 100, 60}, id: :credits)
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport], game_name: game_name}}
  end

  def handle_info({:refresh, game_state}, %{graph: graph} = state) do
    %{points: points, credits: credits, board: board} = game_state

    Graph.build(font: :roboto, font_size: 24)
    |> text("Score: #{points}", translate: {20, 60})
    |> text("Credits: #{credits}", translate: {700 - 100, 60}, id: :credits)
    |> build_scene(board)
    |> push_graph()

    {:noreply, state}
  end

  defp build_scene(graph, board) do
    IO.inspect(board)

    Enum.each(board, fn item ->
      circle(graph, 5, fill: :red, translate: {20 * item.y + 1, 20 * item.x + 1})
    end)

    graph
    # graph |> circle(5, fill: :red, translate: {100, 200})
  end

  def handle_input({:key, {" ", :press, 0}}, _, %{game_name: game_name} = state) do
    if GameServer.game_pid(game_name) != nil do
      GameServer.fire(game_name)
    end

    {:noreply, state}
  end

  def handle_input({:key, {"right", :press, 0}}, _, %{game_name: game_name} = state) do
    if GameServer.game_pid(game_name) != nil do
      GameServer.move_player(game_name, 1)
    end

    {:noreply, state}
  end

  def handle_input({:key, {"left", :press, 0}}, _, %{game_name: game_name} = state) do
    if GameServer.game_pid(game_name) != nil do
      GameServer.move_player(game_name, -1)
    end

    {:noreply, state}
  end

  def handle_input(_, _, state) do
    {:noreply, state}
  end
end
