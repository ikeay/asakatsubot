# coding: utf-8
require 'slack'
require 'redis'
require 'json'
require './settings.rb'

Slack.configure do |config|
  config.token = ASAKATSU_TOKEN
end

def push_remind_msg
  params = {
    token: ASAKATSU_TOKEN,
    channel: '#asakatsu',
    as_user: true,
    text: '明日は朝活！8:30〜です。目覚ましを設定しましょう！！',
  }
  Slack.chat_postMessage(params)
end

if ENV["REDISTOGO_URL"] != nil
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  redis = Redis.new(:host => "127.0.0.1", :port => "6379")
end

json = redis.get(REDIS_KEY)
if json != nil
  body = JSON.parse(json)
  if (Time.at(body['time']) - Time.now).abs < 3600
    push_remind_msg
  end
end
