require 'slack'
require './key.rb'

Slack.configure do |config|
  config.token = TOKEN
end

puts Slack.auth_test


# client = Slack.realtime

# client.on :hello do
#   puts 'Successfully connected.'
# end

# client.on :message do |data|
#   # respond to messages
# end

# client.start