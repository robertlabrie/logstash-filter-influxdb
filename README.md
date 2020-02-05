# logstash-filter-influxdb

Parses InfluxDB [line protocol](https://docs.influxdata.com/influxdb/v1.7/write_protocols/line_protocol_tutorial/) into discreet fields in the Logstash event. This is essentially a wrapper around the [influx parser gem](https://github.com/robertlabrie/influxparser). Four fields are added to the event

* `measurement`: The measurement name from the line protocol
* `tags`: An array of tags in key=value format. The array will be empty if no tags were present
* `fields`: An array of fields in key=value format
* `time`: The timestamp from the measurement. Will be `nil` if there was no timestamp in the event. Times are always in UTC

If the data could not be parsed as valid Influx line protocol, there will be a single attribute added to the event
* `_influxparseerror`: set to true if the measurement could not be parsed

## usage

```
input { 
    stdin{} 
} 

filter { 
    # Multiple events in a single message are valid line protocol so split the event on newlines
    split {
        field => "message"
    }

    # parse the event
    influxdb {
        source => "message"
        target => "point"
        parse_types => true
        time_format => "%Y-%d-%mT%H:%M:%S.%NZ"
    } 

    # drop parse errors -- a better practice might be to write them to some error log
    if ([point][_influxparseerror]) {
        drop {}
    }
}
output {
    stdout { codec => rubydebug }
}
```
given input `weather,location=us-midwest temperature=82 1465839830100400200` the expected output would be
```ruby
{
          "host" => "6108d1baf51e",
       "message" => "weather,location=us-midwest temperature=82 1465839830100400200",
      "@version" => "1",
         "point" => {
               "time" => "2016-13-06T17:43:50.100400209Z",
               "_raw" => "weather,location=us-midwest temperature=82 1465839830100400200",
        "measurement" => "weather",
               "tags" => {
            "location" => "us-midwest"
        },
             "values" => {
            "temperature" => 82.0
        }
    },
    "@timestamp" => 2020-02-05T01:09:55.023Z
}
```
## options
The second parameter for parse_point is a hash array of options. The current options are
* `source`: The attribute containing the raw line protocol to be parsed
  * **default**: `message`
* `target`: The attribute in the event to store the parsed measurement
  * **default**: `point`

* `:parse_types`: Parse data types to ruby types (float, int, bool). If false all values in the fields are treated as strings.
  * **default**: `false`

* `:time_format`: Parses the timestamp attribute (if present) and formats it accoring to a [strftime format](https://apidock.com/ruby/Time/strftime). InfluxDB time is always UTC so is this.
  * **default**: `nil`