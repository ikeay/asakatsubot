require 'date'
require 'slack'
require './key.rb'


Slack.configure do |config|
  config.token = TOKEN
end
client = Slack.realtime

def date_from_wday(str)
    now = Date.today
    now_wday = now.wday
    next_wday = find_wday_num(str)
    if(now_wday == next_wday)
        days_plus = 7
    elsif(now_wday < next_wday)
        days_plus = next_wday - now_wday
    elsif(now_wday > next_wday)
        days_plus = 7 - (now_wday - next_wday)
    else
        days_plus = nil
    end
    now + days_plus
end

def find_wday_num(str)
    case str
    when "日" then
        wday_num = 0
    when "月" then
        wday_num = 1
    when "火" then
        wday_num = 2
    when "水" then
        wday_num = 3
    when "木" then
        wday_num = 4
    when "金" then
        wday_num = 5
    when "土" then
        wday_num = 6
    else
        wday_num = nil
    end
end

def bot_message?(data, name, account)
    return data['subtype'] != 'bot_message' && (data['text'].match("#{name}:") || data['text'].match("<#{account}>:"))
end

def wday_contains?(data)
    if data['text'] =~ /(月|火|水|木|金|土|日)/
        return $1
    end
end

def push_reservation_msg(wday)
    reservation_date = date_from_wday(wday)
    params = {
        token: TOKEN,
        channel: "#asakatsu",
        as_user: true,
        text: "わかりました。#{wday}曜日ですね。#{reservation_date.mon}月#{reservation_date.mday}日#{wday}曜日8:30-予約しました。",
    }
    Slack.chat_postMessage(params)
end

def push_remind_msg
    params = {
        token: TOKEN,
        channel: "#asakatsu",
        as_user: true,
        text: "明日の8:30〜朝活です。タイマーを設定しましょう！！",
    }
    Slack.chat_postMessage(params)
end

client.on :message do |data|
    if bot_message?(data, "asakatsu_bot", "@U0H2JQCAU")
        if wday = wday_contains?(data)
            push_reservation_msg(wday)
        end
    end
end

client.start
