# logstash-filter-influxdb

## usage
```ruby
InfluxParser.parse_point('weather,location=us-midwest temperature="too warm" 1465839830100400200')
```

## options
The second parameter for parse_point is a hash array of options. The current options are

* `:parse_types`: Parse data types to ruby types (float, int, bool). If false all values in the fields are treated as strings. 
  * **default**: `false`

* `:time_format`: Parses the timestamp attribute (if present) and formats it accoring to a [strftime format](https://apidock.com/ruby/Time/strftime). InfluxDB time is always UTC so is this.
  * **default**: `nil`