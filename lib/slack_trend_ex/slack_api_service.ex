defmodule SlackTrendEx.SlackAPIService do
  require Logger

  def channels_list do
    Slack.Web.Channels.list(%{exclude_archived: 1})
    |> Map.fetch!("channels")
  end

  def channels_history(channel_id, oldest, latest) do
    Slack.Web.Channels.history(channel_id, %{count: 1000, oldest: oldest, latest: latest})
    |> Map.fetch!("messages")
    |> remove_bot_messages
  end

  defp remove_bot_messages(messages) do
    messages
    |> Enum.filter(&(not Map.has_key?(&1, "bot_id")))
  end

  def post_message(text, channel_id \\ Application.get_env(:slack, :post_channel)) do
    Slack.Web.Chat.post_message(channel_id, text,
      %{username: "slack-trend-analysis", icon_emoji: ":monolith:", link_names: 1})
  end
end
