defmodule SlackTrendEx do
  def run(num) do
    SlackTrendEx.Aggregate.message_ranking(num)
  end
end
