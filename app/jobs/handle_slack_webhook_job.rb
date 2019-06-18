class HandleSlackWebhookJob < ApplicationJob
  queue_as :default

  def perform(*args)
    event_hash = args[0][:event]

    team = Team.where(team_id: event_hash["team_id"]).first
    user = User.where(uid: event_hash["event"]["user"], team_id: team.id).first
    text = event_hash["event"]["text"]
    channel = event_hash["event"]["channel"]
    # event_ts = args[0][:event]["event"]["event_ts"]

    # Dummy response for testing purposes
    # msg_text = "Got it!"
    # send_slack_message(msg_text, channel, team)

    attached_sent_question = SentQuestion.where(recipent_slack_uid: user.uid).last

    if attached_sent_question.nil?
      msg_text = "Sorry? I haven't said anything."
      send_slack_message(msg_text, channel, team)
    else
      reply = Response.new(
                content: text,
                slack_uid: user.uid,
                sent_question_id: attached_sent_question.id,
                question_id: attached_sent_question.question_id
              )
    end

    if attached_sent_question.question.question_type == "radio"
      # if data.text.to_i == 0 then they sent NaN, 0 is not a valid choice either
      # Checks if the sent int is inside the range of choices available
      if (1..attached_sent_question.question.choices.count).include?(text.to_i) && !text.to_i.zero?
        choice = attached_sent_question.question.choices[(text.to_i - 1)]
        reply.choice_id = choice.id
        reply.save!
      else
        # Checks if there is already a reply to the last asked question
        if attached_sent_question.question.responses.where(slack_uid: user.id).exists?
          msg_text = "Hi? I didn't say anything."
          send_slack_message(msg_text, channel, team)
        else
          # Respondent sent invalid Multiple Choice Question choice
          msg_text = "I don't think that was one of the options. Choose a different one?"
          send_slack_message(msg_text, channel, team)
        end
      end
    else
      if attached_sent_question.question.responses.where(slack_uid: user.id).exists?
        msg_text = "Hello...uh....I didn't say anything."
        send_slack_message(msg_text, channel, team)
      else
        reply.save!
      end
    end
  end

  def send_slack_message(msg_text, channel, team)
    HTTParty.post("https://slack.com/api/chat.postMessage",
      body: {
        token: team.bot_access_token,
        as_user: true, # So it looks like the bot sent it
        channel: channel,
        text: msg_text,
        })
  end
end
