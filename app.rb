# encoding: utf-8
require 'sinatra'
require 'sass'
require 'haml'

require 'json'
require 'etc'
require 'timeout'

class Watcher
  def sparklines
    sparkline_fields.map do |name, method|
      values = checks.map{ |c| c[1].send(method) }
      if values.any?{|v| v != 0}
        [name, values]
      else
        nil
      end
    end.compact
  end
end

Dir['./watchers/*.rb'].each { |f| require f }

host_watchers = (ENV["BOARDY_HOSTS"]||"").split(",").map {|h| HostWatcher.new(h) }
if host_watchers.empty?
  puts "Add some host watchers by setting BOARDYHOSTS=google.com,github.com"
  exit
end

WATCHERS = host_watchers
INTERVAL = ENV["BOARDY_INTERVAL"].to_i rescue 5




def check
  WATCHERS.each do |w|
    status = begin
      Timeout::timeout(INTERVAL) {
        w.check
      }
    rescue Timeout::Error => e
      w.down_status
    end
    w.checks << [Time.now.to_i, status]
    w.checks.shift if w.checks.length > 1000
  end
end

Thread.abort_on_exception = true

Thread.new do
  3.times { check }

  loop do
    check
    sleep INTERVAL
  end
end

check

get '/' do
  haml :index
end

get '/style.css' do
  scss :style
end
