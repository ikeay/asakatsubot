# coding: utf-8
require 'slack'
require 'redis'
require 'json'
require 'date'
require './settings.rb'

Slack.configure do |config|
  config.token = ASAKATSU_TOKEN
end

def push_msg_with_text(text)
  params = {
    token: ASAKATSU_TOKEN,
    channel: '#asakatsu_ch',
    as_user: true,
    text: text,
  }
  Slack.chat_postMessage(params)
end

def push_remind_msg
  push_msg_with_text('明日は朝活！8:30〜です。目覚ましを設定しましょう！！')
end

def push_suggestion_msg
  push_msg_with_text('今週はまだ朝活の予定が入っていないようです。予定を立てましょう！')
end

if ENV["REDISTOGO_URL"] != nil
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  redis = Redis.new(:host => "127.0.0.1", :port => "6379")
end

exists = redis.exists(REDIS_KEY)
if !exists
  today = Date.today
  if (today.wday == 2)
    push_suggestion_msg
  end
end

json = redis.get(REDIS_KEY)
if json != nil
  body = JSON.parse(json)
  if (Time.at(body['time']) - Time.now).abs < 3600
    push_remind_msg
    redis.del(REDIS_KEY)
  end
end
