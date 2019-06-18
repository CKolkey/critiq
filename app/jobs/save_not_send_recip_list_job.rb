class SaveNotSendRecipListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    team = Team.find(args[0][:team_id])
    
    puts "Fetching Member List from SLACK API for Chan: #{args[0][:channel_id]}"
    survey = Survey.find(args[0][:surv_id])
    ml = HTTParty.get("https://slack.com/api/channels.info",
          query: {
            token: team.bot_access_token,
            channel: args[0][:channel_id] })

    ml["channel"]["members"].reject { |x| x == User.find(survey.user_id).uid }.each do |uid|
      GetSlackUserInfoJob.perform_later(uid: uid, surv_id: survey.id, team_id: team.id)
    end
  end
end
