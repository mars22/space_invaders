defmodule SpaceInvaders.GameServer do
  use GenServer
  require Logger

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_name, parent) do
    GenServer.start_link(
      __MODULE__,
      {game_name, parent},
      name: via_tuple(game_name)
    )
  end

  def init({game_name, parent}) do
    game = SpaceInvaders.Game.new()
    Logger.info("Spawned game server process named '#{game_name}'.")
    tick()
    {:ok, {game, parent}}
  end

  defp via_tuple(game_name) do
    {:via, Registry, {SpaceInvaders.GameRegistry, game_name}}
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def reset_game(game_name) do
    GenServer.call(via_tuple(game_name), :reset_game)
  end

  def move_player(game_name, dir) do
    GenServer.call(via_tuple(game_name), {:move_player, dir})
  end

  def fire(game_name) do
    GenServer.call(via_tuple(game_name), :fire)
  end

  def change_parent_pid(game_name, parent_pid) do
    GenServer.call(via_tuple(game_name), {:parent_pid, parent_pid})
  end

  # callbacks

  def handle_call(:reset_game, _from, {_game, parent}) do
    game = SpaceInvaders.Game.new()
    {:reply, game, {game, parent}}
  end

  def handle_call({:move_player, dir}, _from, {game, parent}) do
    game = SpaceInvaders.Game.move_player(game, dir)
    {:reply, game, {game, parent}}
  end

  def handle_call(:fire, _from, {game, parent}) do
    game = SpaceInvaders.Game.fire(game)
    {:reply, game, {game, parent}}
  end

  def handle_call({:parent_pid, parent_pid}, _from, {game, parent}) do
    {:reply, {game, parent_pid}, {game, parent_pid}}
  end

  def handle_info(:refresh, {game, parent}) do
    new_game = SpaceInvaders.Game.step(game)

    case new_game.credits == 0 do
      true ->
        game_map = SpaceInvaders.Game.to_map(new_game)
        Process.send(parent, {:refresh, game_map}, [])
        {:stop, :shutdown, {new_game, parent}}

      false ->
        game_map = SpaceInvaders.Game.to_map(new_game)

        Process.send(parent, {:refresh, game_map}, [])
        tick()
        {:noreply, {new_game, parent}}
    end
  end

  defp tick() do
    Process.send_after(self(), :refresh, 20)
  end
end
