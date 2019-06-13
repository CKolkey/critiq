# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

# START BOT RELATED CONTENT
# require ::File.expand_path('../bot/bot', __FILE__)
#
# Thread.abort_on_exception = true
# Thread.new do
#   Bot.run
# end
# END BOT RELATED CONTENT


run Rails.application
