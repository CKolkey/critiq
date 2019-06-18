class GetSlackUserInfoJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "Fetching recipient INFO from SLACK API for UID:#{args[0][:uid]}"
    team = Team.find(args[0][:team_id])
    info = HTTParty.get("https://slack.com/api/users.info",
                        query: {
                          token: team.bot_access_token,
                          user: args[0][:uid]
                        })
    if info["ok"] == true && info["user"]["id"] != team.bot_user_id
      first_name = info["user"]["real_name"].split(" ")[0]
      last_name  = info["user"]["real_name"].split(" ")[1]
      Recipient.create(survey_id: args[0][:surv_id], uid: args[0][:uid], first_name: first_name, last_name: last_name)
    end
  end
end
