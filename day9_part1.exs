defmodule Garbage do
  def score do
    chars = File.read!("input.txt")
    |> String.split("", trim: true)
    |> List.delete_at(-1)
    
    run(%{next: chars,
          in_trash: false,
          braces: 0,
          score: 0})
  end

  defp run(%{next: []} = state), do: state.score

  defp run(%{in_trash: true} = state) do
    case hd(state.next) do
      ">" ->
        state
        |> Map.put(:in_trash, false)
        |> Map.put(:next, tl(state.next))
        |> run
      "!" ->
        state
        |> Map.put(:next, tl(tl(state.next)))
        |> run
      _ ->
        state
        |> Map.put(:next, tl(state.next))
        |> run
    end
  end

  defp run(state) do
    case hd(state.next) do
      "{" -> 
        state
        |> Map.update!(:braces, &(&1 + 1))
        |> Map.put(:next, tl(state.next))
        |> run
      "}" ->
        state
        |> Map.update!(:score, &(&1 + state.braces))
        |> Map.update!(:braces, &(&1 - 1))
        |> Map.put(:next, tl(state.next))
        |> run
      "<" ->
        state
        |> Map.put(:in_trash, true)
        |> Map.put(:next, tl(state.next))
        |> run
      "!" ->
        state
        |> Map.put(:next, tl(tl(state.next)))
        |> run
      _ ->
        state
        |> Map.put(:next, tl(state.next))
        |> run
    end
  end
end

IO.puts Garbage.score
