defmodule SpaceInvaders.BoardDisplay do
  alias IO.ANSI
  alias SpaceInvaders.{Bullet, PlayerShip, InvaderShip}

  def display(board) do
    print_invaders(board)
  end

  defp print_invaders(board) do
    IO.write("\n")

    column_width = 1
    fields = SpaceInvaders.Board.to_fields_mat(board)

    Enum.each(fields, fn row ->
      print_row(row, column_width)
    end)
  end

  defp print_row(fields, column_width) do
    fields
    |> Enum.map_join("  ", &field_in_ansi_format(&1, column_width))
    |> IO.puts()
  end

  defp field_in_ansi_format(field, column_width) do
    text_in_field_padded(field, column_width)
    |> ANSI.format(true)
    |> IO.chardata_to_string()
  end

  defp text_in_field_padded(field, column_width) do
    field
    |> text_in_field()
    |> pad_trailing(column_width)
  end

  defp text_in_field(field) do
    case field do
      %Bullet{} ->
        [ANSI.reverse_off(), "*"]

      %InvaderShip{visible: visible} ->
        case visible do
          true -> [String.to_atom("red"), "X"]
          false -> [ANSI.reverse_off(), " "]
        end

      %PlayerShip{visible: visible} ->
        case visible do
          true -> [String.to_atom("blue"), "^"]
          false -> [ANSI.reverse_off(), " "]
        end

      _ ->
        [ANSI.reverse_off(), " "]
    end
  end

  defp pad_trailing([color, text], column_width) do
    [color, String.pad_trailing(text, column_width)]
  end
end
