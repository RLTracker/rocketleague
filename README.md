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

# we want to get some generic info + game servers
payload = rl.procencode([["GetGenericDataAll"], ["GetGameServerPingList"]])
response = rl.request "/callproc105/", {}, payload

# parse the response
result = rl.procparse(response.body)
```

The result looks like this:
```ruby
[
  [
    {
      "DataKey" => "Analytics",
      "DataValue" => "1"
    }, {
      "DataKey" => "BugReports",
      "DataValue" => "0"
    }, {
      "DataKey" => "RankEnabled",
      "DataValue" => "1"
    }
  ], [
    {
      "Region" => "ASC",
      "IP" => "103.16.26.248:7717"
    }, {
      "Region" => "EU",
      "IP" => "104.238.188.227:7762"
    }, {
      "Region" => "JPN",
      "IP" => "45.32.19.87:7798"
    }, {
      "Region" => "ME",
      "IP" => "45.32.152.240:7906"
    }, {
      "Region" => "nrt",
      "IP" => "103.16.26.248:7801"
    }, {
      "Region" => "OCE",
      "IP" => "45.32.241.199:7874"
    }, {
      "Region" => "SAM",
      "IP" => "185.50.104.101:7756"
    }, {
      "Region" => "USE",
      "IP" => "104.238.137.154:7758"
    }, {
      "Region" => "USW",
      "IP" => "45.32.206.103:7818"
    }
  ]
]
```