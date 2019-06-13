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
      render json: {:status => 400, :error => "Invalid payload"} and return
    rescue NoMethodError => e
      # missing event handler
      render json: {:status => 418, :error => "I am a teapot"} and return
    end
    # render json: {:status => 200}
  end

  def handle_url_verification(event)
    render json: { status: 200, challenge: event["challenge"] } and return
  end

  def handle_event_callback(event)
    HandleSlackWebhookJob.perform_later(event: event)
    render json: {:status => 200}
  end
end
