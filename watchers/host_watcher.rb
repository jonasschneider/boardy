# encoding: utf-8
class HostWatcher < Watcher
  attr_reader :checks

  class Status < Struct.new(:ping, :load)
    def main_num
      ping
    end

    def main_unit
      "ms"
    end

    def down?
      ping <= 0
    end
  end

  def sparkline_fields
    { "Load" => :load }
  end

  def up?
    !checks.last[1].down?
  end

  def number
    x=checks.last
    x[1].down? ? '—' : "#{x[1].ping.ceil}ms"
  end

  def name
    @host
  end

  def initialize(host)
    @host = host
    @checks = []
    `gtimeout 5 ssh -o "BatchMode yes" #{@host} cat /proc/loadavg 2> /dev/null`
    @can_login = $?.exitstatus == 0
  end

  def check
    ping = `ping -c 1 -t 5 #{@host} 2> /dev/null | tail -1| awk '{print $4}' | cut -d '/' -f 2`.to_f
    if $?.exitstatus == 0 && ping > 0
      if @can_login
        load = `gtimeout 5 ssh -o "BatchMode yes" #{@host} cat /proc/loadavg 2> /dev/null| cut -d ' ' -f 2`.to_f
      else
        load = 0
      end
      Status.new(ping, load)
    else
      down_status
    end
  end

  def down_status
    Status.new(0,0)
  end
end
