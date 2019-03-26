defmodule SpaceInvadersScenic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives
  import Scenic.Components

  @note """
    Space invaders

    Score: 0
  """

  @graph Graph.build(font: :roboto, font_size: 36)
         |> text("Space invaders", translate: {20, 60}, font_size: 36)
         |> button("Start Game",
           id: :start_game_button,
           translate: {120, 120},
           button_font_size: 36,
           width: 200,
           height: 60,
           theme: :warning,
           active: :red
         )

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {width, _}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph = push_graph(@graph)
    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end

  # ----------------------------------------------------------------------------
  def filter_event({:click, :start_game_button}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, {SpaceInvadersScenic.Scene.Game, name: "game"})
    {:stop, state}
  end
end
