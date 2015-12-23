# ライブラリ
require 'sinatra'
require 'slack'

# 開発環境用ライブラリ
if settings.development?
  require 'pry'
end

TOKEN = ENV['ASAKATSU_TOKEN']
ONE_WEEK = 7

Slack.configure do |config|
  config.token = TOKEN
end

def wday_contains?(data)
    if data['text'] =~ /(月|火|水|木|金|土|日)/
        return $1
    end
end

def date_from_wday(date_str)
    now = Date.today
    now_wday = now.wday
    next_wday = find_wday_num(date_str)
    if(now_wday == next_wday)
        days_plus = ONE_WEEK
    elsif(now_wday < next_wday)
        days_plus = next_wday - now_wday
    elsif(now_wday > next_wday)
        days_plus = ONE_WEEK - (now_wday - next_wday)
    else
        days_plus = nil
    end
    now + days_plus
end

def find_wday_num(str)
    case str
    when '日' then
        wday_num = 0
    when '月' then
        wday_num = 1
    when '火' then
        wday_num = 2
    when '水' then
        wday_num = 3
    when '木' then
        wday_num = 4
    when '金' then
        wday_num = 5
    when '土' then
        wday_num = 6
    else
        wday_num = nil
    end
end

def push_reservation_msg(wday)
    reservation_date = date_from_wday(wday)
    params = {
        token: TOKEN,
        channel: '#asakatsu',
        as_user: true,
        text: "わかりました。#{wday}曜日ですね。#{reservation_date.mon}月#{reservation_date.mday}日#{wday}曜日8:30-予約しました。\nアラームを#{alerm_time.to_s}に設定しました！",
    }
    Slack.chat_postMessage(params)
end

def push_remind_msg
    params = {
        token: TOKEN,
        channel: '#asakatsu',
        as_user: true,
        text: '明日は朝活！8:30〜です。タイマーを設定しましょう！！',
    }
    Slack.chat_postMessage(params)
end

get '/webhook' do
    if wday = wday_contains?(params[:text])
        push_reservation_msg(wday)
    end
end