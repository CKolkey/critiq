class Response < ApplicationRecord
  belongs_to :question
  belongs_to :choice, optional: true

  after_commit :send_next_question, on: :create

  private

  def send_next_question
    puts "** Inside Response Model **"
    # Filter sent questions for those only pertaining to this user
    # Return only the last-asked question ID
    last_question_id = SentQuestion.where(recipent_slack_uid: self.slack_uid).last.question_id
    # Sends next question to user:
    binding.pry
    SendSlackMessageIndividualJob.perform_later(uid: self.slack_uid, question_id: last_question_id, team_id: self.team.id)
  end
end
