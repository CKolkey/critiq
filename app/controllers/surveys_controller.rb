class SurveysController < ApplicationController
  def index
    # search functionality => queries
    if params[:query].present?
      sql_query = " \
        surveys.title ILIKE :query \
        OR surveys.description ILIKE :query \
        OR questions.name ILIKE :query
      "
      # get surveys that belong to the current user AND fit the search params
      @surveys = current_user.surveys
                             .left_outer_joins(:questions)
                             .where(sql_query, query: "%#{params[:query]}%")
                             .distinct
                             .sort_by(&:created_at).reverse
    else
      @surveys = current_user.surveys.sort_by(&:created_at).reverse
    end
    @survey = Survey.new
    if params[:id].present?
      @questions = Survey.find(params[:id]).display_responses
    else
      @questions = nil
    end
  end

  def new
    @survey = Survey.new
  end

  def show
    respond_to do |format|
      format.html { redirect_to surveys_path(id: params[:id]) }
      format.js
    end
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user = current_user
    if @survey.save
      redirect_to edit_survey_path(@survey)
    else
      render :new
    end
  end

  def edit
    @survey = Survey.find(params[:id])
    # Fetch Slack Chan /cannot/ be an async job
    fetch_slack_channels = GetSlackChannelsJob.perform_now(team_id: current_user.team.id)
    if fetch_slack_channels["ok"]
      # Format for Select2. Very picky.
      channel_array = []
      fetch_slack_channels["channels"].each do |chan|
        channel_array << {id: chan["id"], name: chan["name"]}
      end
      @slackchannels = channel_array
    else
      @slackchannels = { error: true }
    end
  end

  # updates and sends out survey
  def update
    @survey = Survey.find(params[:id])
    if @survey.update(survey_params)

      if @survey.recipients.empty?
        SaveNotSendRecipListJob.perform_now(channel_id: @survey.channel_id, surv_id: @survey.id, team_id: @survey.user.team.id)
      end

      if params[:commit] == "Send & Save"
        @survey.send_first_question
      elsif params[:commit] == "Save"
        @survey.published = false
        @survey.save
      end

      redirect_to survey_path(@survey)
    else
      render :edit
    end
  end

  def destroy
    @survey = Survey.find(params[:id])
    @survey.destroy
    respond_to do |format|
      format.html { redirect_to surveys_path }
      format.js
    end
  end

  private

  def survey_params
    params.require(:survey).permit(:title, :description, :published, :channel_id, questions_attributes: [:name, :id, :question_type, :multiple_choice, choices_attributes: [:name, :_destroy, :id]])
  end
end
