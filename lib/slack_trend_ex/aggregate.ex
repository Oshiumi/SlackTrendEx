defmodule SlackTrendEx.Aggregate do
  defp _count_messages(channel_id, oldest, latest)
    when oldest < latest do
    messages = SlackTrendEx.SlackAPIService.channels_history(channel_id, oldest, latest)
    count =  length(messages)
    if count < 1000 do
      count
    else
      next_latest = List.first(messages) |> Map.fetch!("ts")
      _count_messages(channel_id, oldest, next_latest) + count - 1
    end
  end
  defp _count_messages(_, _, _), do: 0

  def count_messages(channel) do
    receive do
      pid ->
        now = :os.system_time(:seconds)
        send pid,
        {self, %{"name" => channel["name"],
                   "count" => _count_messages(channel["id"], now-60*60*24, now)}}
    end
  end

  def message_ranking(num) do
    SlackTrendEx.SlackAPIService.channels_list
    |> Enum.map(fn channel ->
      pid = spawn(SlackTrendEx.Aggregate, :count_messages, [channel])
      send pid, self
      pid
    end)
    |> Enum.map(fn pid ->
      receive do {^pid, result} -> result end
    end)
    |> Enum.sort(&(&1["count"] > &2["count"]))
    |> Enum.take(num)
  end
end
