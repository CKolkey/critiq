class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def webhook
    begin
      event = JSON.parse(request.body.read)
      method = "handle_" + event['type'].tr('.', '_')

      if event['token'] == ENV['SLACK_VERIF_TOKEN']
        self.send method, event
      end
    rescue JSON::ParserError => e
      render json: { status: 400, error: "Invalid payload" } and return
    rescue NoMethodError => e
      # missing event handler
      render json: { status: 418, error: "I am a teapot" } and return
    end
    # Not needed because methods below all render a JSON response
    # render json: {:status => 200}
  end

  def installbot
    # Handles oAuth path for adding critiq to workspaces
    if params[:code]
      response = HTTParty.post("https://slack.com/api/oauth.access",
                  body: { client_id: ENV['SLACK_CLIENT_ID'],
                          client_secret: ENV['SLACK_CLIENT_SECRET'],
                          code: params[:code],
                          redirect_uri: 'http://localhost:3000/auth/installbot'
                        })

      if response["ok"]
        x = Team.new(
              team_id: response["team_id"],
              name: response["team_name"],
              token: response["access_token"],
              bot_user_id: response["bot"]["bot_user_id"],
              bot_access_token: response["bot"]["bot_access_token"]
            )

        if x.save
          # Install Sucessful, redirect to home page, flash message confirming sucess
          CreateSlackMembersJob.perform_later(team_id: x.id)
          flash[:notice] = 'Successfully Installed Ciritiq to your Workspace!'
          redirect_to root_path
        else
          # Something went wrong and the team wasnt created
          flash[:notice] = "I think Critiq is already installed to this workspace. Try loggin in!"
          redirect_to root_path
        end
      else
        # Bad HTTP Response from POST
        flash[:notice] = "Bad HTTP Response. Maybe it's Slack's fault? Try again later."
        redirect_to root_path
      end
    else
      # No OAuth Code in Params
      flash[:notice] = "No oAuth code in parameters. Don't know how you did this, but...don't?"
      redirect_to root_path
    end
  end

  private

  def handle_url_verification(event)
    render json: { status: 200, challenge: event["challenge"] } and return
  end

  def handle_event_callback(event)
    puts "> Ignoring Bot Event" if event["event"]["bot_id"]
    HandleSlackWebhookJob.perform_later(event: event) unless event["event"]["bot_id"]
    render json: { status: 200 }
  end
end
