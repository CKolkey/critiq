
class SendSlackMessageAllJob < ApplicationJob
  queue_as :default

  # Args: ARRAY of a HASH: Question_ID & Survey_ID
  def perform(*args)
    puts ""
    puts "* Sending in 5s..."
    sleep(5)
    puts "* Inside SendSlackMessageAllJob *"

    puts "> Finding Survey with id #{args[0][:survey_id]}"
    survey = Survey.find(args[0][:survey_id])
    puts "> Finding Question with id #{args[0][:question_id]}"
    question = Question.find(args[0][:question_id])
    team = User.find(survey.user_id).team

    puts "> Fetching member list from SLACK API (not async)"
    member_list = HTTParty.get("https://slack.com/api/channels.info",
                  query: {
                    token: team.bot_access_token,
                    channel: survey.channel_id })

    # Now handled in Controller
    # member_list["channel"]["members"].reject { |x| x == User.find(survey.user_id).uid }.each do |uid|
    #   GetSlackUserInfoJob.perform_later(uid: uid, surv_id: args[0][:survey_id], team_id: xxx)
    # end



    sender_fn = "#{User.find(survey.user_id).first_name.capitalize}"
    sender_ln = "#{User.find(survey.user_id).last_name.capitalize}"
    others = member_list["channel"]["members"].count - 1

    message_text = "Hi! #{sender_fn} #{sender_ln} wants a Critiq. #{others.to_words.capitalize} other people have been messaged and everyone's responses will be anonymized. #{sender_fn} asks:\n"

    puts "> Beginning to iterate over member list..."
    member_list["channel"]["members"].each do |member_uid|
      # Put this in the above line before '.each' to prevent critiq's from being sent to their creator
      # .reject { |x| x == User.find(survey.user_id).uid }

      send_message(member_uid, message_text, team)

      if question.question_type == 'radio'
        puts "> Question is MC"
        send_message_multiple_choice(member_uid, question, team)
      else
        puts "> Question is NOT MC"
        send_message(member_uid, question.name, team)
      end

      puts ">> Creating SentQuestion entry for Question: #{args[0][:question_id]}, User: #{member_uid}"
      SentQuestion.create!(question_id: args[0][:question_id], recipent_slack_uid: member_uid)

    end
    puts "> Finished sending all messages <"

  end

  private

  def send_message(target_uid, text, team)
    puts "> Sending regular message to #{target_uid}"
    HTTParty.post("https://slack.com/api/chat.postMessage",
      body: {
        token: team.bot_access_token,
        as_user: true, # So it looks like the bot sent it
        channel: target_uid, # Opens DM with user
        text: text,
        })
  end

  def send_message_multiple_choice(target_uid, question, team)
    puts "> Sending MC message to #{target_uid}"
    question_text = "#{question.name}\n(Please respond with the number of your choice)"
    send_message(target_uid, question_text, team)

    question.choices.each_with_index do |choice, index|
      puts "> Sending Choice no.#{index + 1}: '#{choice.name}'"
      choice_text = "#{index + 1}: #{choice.name}"
      send_message(target_uid, choice_text, team)
    end
  end
end
