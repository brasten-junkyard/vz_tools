require 'rubygems'
require File.dirname(__FILE__) + '/../../lib/vz'
require 'eventmachine'
#require 'ruby-debug'
#Debugger.wait_connection = true
#Debugger.start_remote

#host = ARGV.shift
#user = ARGV.shift
#pass = ARGV.shift

Vz.logger.level = Logger::DEBUG

class LogFormatter
  def call(severity, time, progname, msg)
    "#{time.strftime('%m/%d-%H:%M:%S')}: #{msg}"
  end
end

Vz.logger.formatter = LogFormatter.new

Vz.log(:debug, "Testing...")

puts "Making Connection..."
#puts " --> Host: #{host}"
#puts " --> User: #{user}"
#puts " --> Pass: #{pass}"

@conn =
  Vz::Connector::Interface::Connection.new( ARGV.shift, :port => 4433, :username => ARGV.shift, :password => ARGV.shift )


@conn.perf_mon.start_monitor(
  :eid_list       => { :eid => '95c11c1f-fb4f-0a4b-9fdb-6e017a01a7ef' },
  :class          => { :name => 'counters_vz_net', :instance => nil },
  :report_period  => 10
)

#debugger
