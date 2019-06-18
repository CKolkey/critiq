class Bot < SlackRubyBot::Bot
  # command 'say' do |client, data, match|
  #   #Rails.cache.write next_id, { text: match['expression'] }
  #   client.say(channel: data.channel, text: match['expression'])
  # end
  #
  command 'help' do |client, data, match|
    client.say(channel: data.channel, text: "HELP: Thse are the following commands you have access to:")
    client.say(channel: data.channel, text: "HELP: None. Sorry.")
  end
end


# Monkeypatch for the UNKNOWN COMMAND error, to instead save the response without a keyword

class Unknown < SlackRubyBot::Commands::Base
  match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)

  def self.call(client, data, _match)
    # Slackbotdev.create!(content: data.text, slack_channel: data.channel, slack_user: data.user)
    attached_sent_question = SentQuestion.where(recipent_slack_uid: data.user).last
    reply = Response.new(
              content: data.text,
              slack_uid: data.user,
              sent_question_id: attached_sent_question.id,
              question_id: attached_sent_question.question_id
            )

    if attached_sent_question.question.question_type == "radio"
      # if data.text.to_i == 0 then they sent NaN, 0 is not a valid choice either
      # Checks if the sent int is inside the range of choices available
      if (1..attached_sent_question.question.choices.count).include?(data.text.to_i) && !data.text.to_i.zero?
        choice = attached_sent_question.question.choices[(data.text.to_i - 1)]
        reply.choice_id = choice.id
        reply.save!
      else
        # Checks if there is already a reply to the last asked question
        if attached_sent_question.question.responses.where(slack_uid: data.user).exists?
          client.say(channel: data.channel, text: "I didn't say anything.")
        else
          client.say(channel: data.channel, text: "I don't think that was one of the options. Choose a different one?")
        end
      end
    else
      if attached_sent_question.question.responses.where(slack_uid: data.user).exists?
        client.say(channel: data.channel, text: "I didn't say anything.")
      else
        reply.save!
      end
    end
  end
end
