class CreateSlackMembersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Creates a list of members of a workgroup, just First name/ Last name/
    # and UID for purposes of listing later w/o needing to parse large chunks
    # of data from slack. Part of Team INIT process.

    team = Team.find(args[0][:team_id])

    slack_channels = GetSlackChannelsJob.perform_now(team_id: args[0][:team_id])

    channel_array = []
    slack_channels["channels"].each do |chan|
      # Makes array of every channel ID (string) in workspace
      channel_array << chan["id"]
    end

    member_array = []
    channel_array.each do |channel|
      info = HTTParty.get("https://slack.com/api/channels.info",
              query: {
                token: team.bot_access_token,
                channel: channel })
      if info["ok"]
        # Makes array-of-arrays of every member of every channel in workspace
        member_array << info["channel"]["members"]
      end
    end

    member_array.flatten.uniq.each do |member|
      # creates a 'member' object for everyone in a workspace
      get_user_info_and_create(member, team)
    end
  end

  def get_user_info_and_create(uid, team)
    info = HTTParty.get("https://slack.com/api/users.info",
             query: {
               token: team.bot_access_token,
               user: uid
             })
    if info["ok"] && !info["user"]["is_bot"]
      Member.create(
        team_id: team.id,
        uid: uid,
        first_name: info["user"]["real_name"].split.first,
        last_name: info["user"]["real_name"].split.last
      )
    end
  end
end
