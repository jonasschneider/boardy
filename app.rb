# encoding: utf-8
require 'sinatra'
require 'sass'
require 'haml'

require 'json'
require 'etc'
require 'timeout'

WATCHERS = host_watchers
INTERVAL = ENV["BOARDY_INTERVAL"].to_i rescue 5

class HostWatcher
  attr_reader :statuses

  def up?
    !(statuses.last[1] == :down)
  end

  def number
    #statuses.select{|s|s[1] == :up}.length / statuses.length
    x=statuses.last
    x[1] == :down ? '—' : "#{x[1]}ms"
  end

  def name
    @host
  end

  def initialize(host)
    @host = host
    @statuses = []
  end

  def check
    ping_count = 1
    response_time = `ping -c 1 -t 5 #{@host} 2> /dev/null | tail -1| awk '{print $4}' | cut -d '/' -f 2`.to_f
    if $?.exitstatus == 0 && response_time > 0
      response_time
    else
      :down
    end
  end
end

host_watchers = (ENV["BOARDY_HOSTS"]||"").split(",").map {|h| HostWatcher.new(h) }
if host_watchers.empty?
  puts "Add some host watchers by setting BOARDYHOSTS=google.com,github.com"
  exit
end

def check
  WATCHERS.each do |w|
    s = begin
      Timeout::timeout(INTERVAL) {
        w.check
      }
    rescue Timeout::Error => e
      :down
    end
    w.statuses << [Time.now.to_i, s]
    w.statuses.shift if w.statuses.length > 1000
  end
end

Thread.abort_on_exception = true

Thread.new do
  loop do
    check
    sleep INTERVAL
  end
end

3.times { check }

get '/' do
  haml :index
end

get '/style.css' do
  scss :style
end
