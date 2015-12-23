# coding: utf-8
# ライブラリ
require 'sinatra'
require 'slack'
require 'redis'
require 'json'
require './settings.rb'

# 開発環境用ライブラリ
if settings.development?
  require 'pry'
end

ONE_WEEK = 7

def wday_contains?(text)
  if text =~ /(月|火|水|木|金|土|日)/
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

def get_reservation_msg(wday, date)
  "わかりました。#{wday}曜日ですね。#{date.mon}月#{date.mday}日#{wday}曜日8:30-に予約しました。\n"
end

def get_alerm_time(date)
  alerm_date = date - 1
  Time.new(alerm_date.year, alerm_date.mon, alerm_date.mday, 22, 0, 0, "+09:00")
end

def get_alerm_msg(time)
  "アラームを#{time.to_s}に設定しました！\n"
end

def store_to_redis(time)
  if ENV["REDISTOGO_URL"] != nil
    uri = URI.parse(ENV["REDISTOGO_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    redis = Redis.new(:host => "127.0.0.1", :port => "6379")
  end
  redis.set(REDIS_KEY, { time: time.to_i }.to_json)
end

post '/webhook' do
  if wday = wday_contains?(params[:text])
    date = date_from_wday(wday)
    msg  = get_reservation_msg(wday, date)
    time = get_alerm_time(date)
    msg += get_alerm_msg(time)
    puts msg
    store_to_redis(time)
    { text: msg }.to_json
  else
    { text: '無効な曜日です！' }.to_json
  end
end

