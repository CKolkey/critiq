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
    if params[:code]
      response = HTTParty.post("https://slack.com/api/oauth.access",
        body: { client_id: ENV['SLACK_CLIENT_ID'],
                client_secret: ENV['SLACK_CLIENT_SECRET'],
                code: params[:code],
                redirect_uri: 'http://localhost:3000/auth/installbot',
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
          # REDIRECT TO HOME PAGE AND FLASH MESSAGE THAT INSTALL WAS SUCESSFFULL
          
        else
          # SOMETHING went wrong and the team wasnt created

        end

      end
    end
  end

  private

  def handle_url_verification(event)
    render json: { status: 200, challenge: event["challenge"] } and return
  end

  def handle_event_callback(event)
    puts "> Ignoring Bot Event" if event["event"]["bot_id"]
    HandleSlackWebhookJob.perform_later(event: event) unless event["event"]["bot_id"]
    render json: {:status => 200}
  end
end
