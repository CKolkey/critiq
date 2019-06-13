class HandleSlackWebhookJob < ApplicationJob
  queue_as :default

  def perform(*args)
    event_hash = args[0][:event]
    team_id = event_hash["team_id"]
    text = event_hash["event"]["text"]
    user_id = event_hash["event"]["user"]
    channel = event_hash["event"]["channel"]
    # event_ts = args[0][:event]["event"]["event_ts"]

    msg_text = "Got it!"
    send_slack_message(msg_text, channel)

  #   attached_sent_question = SentQuestion.where(recipent_slack_uid: user_id).last
  #   reply = Response.new(
  #             content: text,
  #             slack_uid: user_id,
  #             sent_question_id: attached_sent_question.id,
  #             question_id: attached_sent_question.question_id
  #           )
  #
  #   if attached_sent_question.question.question_type == "radio"
  #     # if data.text.to_i == 0 then they sent NaN, 0 is not a valid choice either
  #     # Checks if the sent int is inside the range of choices available
  #     if (1..attached_sent_question.question.choices.count).include?(text.to_i) && !text.to_i.zero?
  #       choice = attached_sent_question.question.choices[(text.to_i - 1)]
  #       reply.choice_id = choice.id
  #       reply.save!
  #     else
  #       # Checks if there is already a reply to the last asked question
  #       if attached_sent_question.question.responses.where(slack_uid: user_id).exists?
  #         msg_text = "I didn't say anything."
  #         send_slack_message(msg_text, channel)
  #       else
  #         msg_text = "I don't think that was one of the options. Choose a different one?"
  #         send_slack_message(msg_text, channel)
  #       end
  #     end
  #   else
  #     if attached_sent_question.question.responses.where(slack_uid: user_id).exists?
  #       msg_text = "I didn't say anything."
  #       send_slack_message(msg_text, channel)
  #     else
  #       reply.save!
  #     end
  #   end
  end

  def send_slack_message(msg_text, channel)
    # Need to save API token for each team, and load that specific one here
    HTTParty.post("https://slack.com/api/chat.postMessage",
      body: {
        token: ENV["SLACK_BOT_OAUTH_TOKEN"],
        as_user: true, # So it looks like the bot sent it
        channel: channel,
        text: msg_text,
        })
  end
end
