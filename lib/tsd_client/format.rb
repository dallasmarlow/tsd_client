require 'uri'

module TSD
  module Format
    def self.time input
      case input.class.name
      when 'Time'
        input.strftime '%Y/%m/%d-%H:%M:%S'
      when 'Date'
        time input.to_time
      when 'Fixnum'
        time Time.at input
      else
        input
      end
    end

    def self.tags tags
      tags.collect do |tag, value|
        [tag, value].join '='
      end
    end

    def self.query_metric options
      raise 'must provide key: :metric' unless options[:metric]
      options = {aggregator: 'sum', rate: false}.merge options

      metric_query = [options[:aggregator]]
      metric_query << options[:downsample] if options[:downsample]
      metric_query << 'rate' if options[:rate]

      if options[:tags]
        metric_query << [options[:metric], '{' + tags(options[:tags]).join(',') + '}'].join
      else
        metric_query << options[:metric]
      end

      metric_query.join ':'
    end

    def self.query options
      raise 'must provide key: :start' unless options[:start]
      options_filter = [:metric, :aggregator, :rate, :downsample, :tags]

      # process query params
      params = options.reduce({m: query_metric(options)}) do |params, (option, value)|
        unless options_filter.include? option
          params[option] = case option
          when :start, :end # time formatting
            time value
          else
            value
          end        
        end

        params
      end

      # assemble query
      URI.escape '/q?' + params.map {|option, value| [option, value].join('=')}.unshift('ascii').join('&')      
    end

    def self.put options
      [:metric, :value].any? {|key| raise "missing key: #{key}" unless options.has_key? key}
      options  = {time: Time.now, tags: {}}.merge options

      ['put', options[:metric], options[:time].to_i, options[:value], tags(options[:tags])].flatten.join("\s")
    end
  end
end
