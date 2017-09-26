defmodule SlackTrendEx.Aggregate do
  def count_messages(channel_id, api, oldest, latest) do
    _count_messages(channel_id, api, oldest, latest, [])
    |> length
  end
  defp _count_messages(channel_id, api, oldest, latest, messages)
  when oldest < latest do
    m = messages ++ api.channels_history(channel_id, oldest, latest)
    next_latest = List.last(m)
    _count_messages(channel_id, api, oldest, next_latest, m)
    m
  end
end
