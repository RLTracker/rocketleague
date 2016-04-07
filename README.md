# RocketLeague

*Who needs standards?* ¯\\\_(ツ)\_/¯

A work in progress ruby gem for the Rocket League API.

## Example usage

```ruby
require "rocketleague"

# these parameters seem to change very rarely
rl = RocketLeague::API.new "https://psyonix-rl.appspot.com", 342373649, "Steam", "dUe3SE4YsR8B0c30E6r7F2KqpZSbGiVx", "pX9pn8F4JnBpoO8Aa219QC6N7g18FJ0F"

# let's start a session!
rl.login 123456789, "MyUserName", "MyAuthCode"

# we want to get some generic info
payload = rl.procencode([["GetGenericDataAll"]])
res = rl.request "/callproc105/", {}, payload)

# use this otherwise
# response parsing is TBI
puts res.body
```
