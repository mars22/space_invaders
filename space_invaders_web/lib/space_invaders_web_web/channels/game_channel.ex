defmodule SpaceInvadersWebWeb.GameChannel do
  use Phoenix.Channel

  alias SpaceInvaders.{GameServer, GameSupervisor}

  def join("game:space_invaders", _params, socket) do
    {:ok, socket}
  end

  def handle_in("start_game", %{"name" => game_name}, socket) do
    case GameServer.game_pid(game_name) do
      pid when is_pid(pid) -> GameServer.change_parent_pid(game_name, socket.channel_pid)
      _ -> GameSupervisor.start_game(game_name, socket.channel_pid)
    end

    broadcast!(socket, "start_game", %{state: game_name})
    {:noreply, socket}
  end

  def handle_in("move_player", %{"name" => game_name, "dir" => dir}, socket) do
    if GameServer.game_pid(game_name) != nil do
      GameServer.move_player(game_name, dir)
    end

    {:noreply, socket}
  end

  def handle_in("fire", %{"name" => game_name}, socket) do
    if GameServer.game_pid(game_name) != nil do
      GameServer.fire(game_name)
    end

    {:noreply, socket}
  end

  def handle_in("reset_game", %{"name" => game_name}, socket) do
    if GameServer.game_pid(game_name) != nil do
      GameServer.reset_game(game_name)
    end

    {:noreply, socket}
  end

  def handle_info({:refresh, state}, socket) do
    broadcast!(socket, "state", %{state: state})
    {:noreply, socket}
  end
end
