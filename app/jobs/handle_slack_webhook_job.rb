class HandleSlackWebhookJob < ApplicationJob
  queue_as :default

  def perform(*args)
    event_hash = args[0][:event]
    team_id = event_hash["team_id"]
    text = event_hash["event"]["text"]
    user_id = event_hash["event"]["user"]
    channel = event_hash["event"]["channel"]
    # event_ts = args[0][:event]["event"]["event_ts"]


    puts "Jobe well done!"
  end
end
