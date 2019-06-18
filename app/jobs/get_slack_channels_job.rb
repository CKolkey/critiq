class GetSlackChannelsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Returns a HASH that is a list of all channels
    team = Team.find(args[0][:team_id])

    puts "> Fetching channel list from SLACK API"
    HTTParty.get("https://slack.com/api/conversations.list",
      query: {
        token: team.bot_access_token,
        types: "public_channel",
        exclude_archived: "true"
         })
  end
end
