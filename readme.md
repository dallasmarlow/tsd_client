```ruby
tsd = TSD::Client.new host: '0.0.0.0',
                      port: 4242,
                      timeout: 120

# query
tsd.query metric: 'cpu',
          start:  '1h-ago'

tsd.query metric: 'load',
          start:  Time.now - 7200,
          end:    Time.now - 3600,
          downsample: '10m-avg'

tsd.query metric: 'memcached',
          start:  1363970875,
          rate:   true,
          tags:   {
            host: Socket.gethostname,
            memcached_command: 'get',
          }

# put
tsd.put   metric: 'temperature', value: 72

tsd.put   metric: 'request',
          value:  0.4323,
          time:   Time.at(1363970890),
          tags:   {
            request_id:     'latency',
            application_id: 'alpha',
          }
```
