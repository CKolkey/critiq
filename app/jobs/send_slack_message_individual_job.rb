class SendSlackMessageIndividualJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts ""
    puts "* Inside SendSlackMessageIndividual *"

    # Args: ARRAY of a HASH: Question_ID & target UID
    target_uid = args[0][:uid]
    team = Team.find(args[0][:team_id])

    puts "> Finding Next Question after Question:id:#{args[0][:question_id]}"
    next_question = find_next_question(args[0][:question_id], args[0][:uid])

    # Set Message text: if there are no more questions to ask, send a thank you message
    if next_question.nil?
      if Question.find(args[0][:question_id]).survey.user.first_name
        sender = Question.find(args[0][:question_id]).survey.user.first_name
        question_text = "Thats all, thanks 👋  We'll anonymize your response and send it to #{sender} once enough people have replied!"
      else
        question_text = "Thats all, thanks 👋  We'll anonymize your response and send it in once enough people have replied!"
      end
    else
      sender = "#{next_question.survey.user.first_name.capitalize}"
      question_text = "#{sender} asks: #{next_question.name}"
    end


    if next_question != nil && next_question.question_type == 'radio'
      send_message_multiple_choice(target_uid, next_question, team)
    else
      send_message(target_uid, question_text, team)
    end

    unless next_question.nil?
      puts ">> Creating SentQuestion entry for Question: #{args[0][:question_id]}, User: #{target_uid}"
      SentQuestion.create!(question_id: next_question.id, recipent_slack_uid: target_uid)
    end


    puts "Finished sending message to #{target_uid}!"

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

  def find_next_question(question_id, uid)
    # Array of all questions in same survey
    associated_questions = Question.find(question_id).survey.questions
    # Find current question's index in array
    question_index = associated_questions.index { |x| x.id == question_id }
    # Determine the last question that was
    last_question_sent = SentQuestion.where(recipent_slack_uid: uid).last.question_id

    # if the last question sent was the last question in the array, there are no more questions to ask
    if last_question_sent == associated_questions.last.id
      return nil
    else
      # Return the next question object that has NOT been asked yet
      return associated_questions[question_index + 1]
    end
  end
end
