class HandleSlackWebhookJob < ApplicationJob
  queue_as :default

  def perform(*args)
    event = args[0]['event']
    puts event
    # Do something later
  end
end
