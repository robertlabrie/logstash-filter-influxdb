# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "influxparser"

# Add any asciidoc formatted documentation here
# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Influxdb < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example { message => "My message..." }
  # }
  config_name "influxdb"

  # Replace the message with this value.
  config :source, :validate => :string, :default => "message"

  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)
    
    point = InfluxParser.parse_point(event.get(@source))

    if point
      event.set('point', point)
    else
      event.set('point', {'_influxparseerror' => true })
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

end # class LogStash::Filters::Influxdb