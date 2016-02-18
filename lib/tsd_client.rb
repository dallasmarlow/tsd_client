$:.unshift File.join File.dirname(__FILE__), 'tsd_client'

require 'socket'
require 'timeout'
require 'net/http'
require 'tsd_client/format'

module TSD
  class Client
    def initialize options = {}
      @options = {
        host:    '0.0.0.0',
        port:    4242,
        timeout: 120, # seconds
        retries: 3,
        retry_interval: 1, # second
      }.merge options

      connect
    end

    def connect
      @socket = TCPSocket.open @options[:host], @options[:port]
    end

    def query options
      response = Timeout::timeout @options[:timeout] do
        Net::HTTP.start @options[:host], @options[:port] do |http|
          http.request Net::HTTP::Get.new Format.query options
        end
      end

      if response.kind_of? Net::HTTPSuccess
        response.body.split("\n").map do |record|
          metric, timestamp, value, *tags = record.split "\s"

          Hash[[:metric, :time, :value, :tags].zip([
            metric, Time.at(timestamp.to_i), value.to_f, Hash[tags.map {|tag| tag.split('=')}]])]
        end
      else
        raise 'query failed: ' + response.code
      end
    end

    def put options, retries = @options[:retries]
      Timeout::timeout @options[:timeout] do
        begin
          @socket.puts Format.put options
          response, _, _ = @socket.recvmsg_nonblock rescue nil
          response.chomp if response
        rescue Exception => e
          if retries > 0
            sleep @options[:retry_interval]
            $stderr.puts "Error: #{e}, retrying \##{retries}"
            retries -= 1
            # try to reconnect
            connect
            retry
          else
            raise e
          end
        end
      end
    end

  end
end
