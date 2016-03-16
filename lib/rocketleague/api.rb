require "uri"
require "net/http"
require "net/https"

module RocketLeague
  class API
    DEFAULT_HEADERS = {
      "Content-Type" =>"application/x-www-form-urlencoded",
      "Environment" =>"Prod",
      "User-Agent" =>"UE3-TA,UE3Ver(10897)",
      "Cache-Control" =>"no-cache"
    }

    def initialize(api_base = "https://psyonix-rl.appspot.com", buildid = 342373649, platform = "Steam", loginsecretkey = "dUe3SE4YsR8B0c30E6r7F2KqpZSbGiVx", playername, playerid, authcode)
      @api_base = api_base
      @BuildID = buildid
      @Platform = platform
      @LoginSecretKey = loginsecretkey
      @PlayerName = playername
      @PlayerID = playerid
      @AuthCode = authcode
    end

    def login
      request "/auth/", { "LoginSecretKey" => @LoginSecretKey }, {
        "PlayerName" => @PlayerName,
        "PlayerID" => @PlayerID,
        "Platform" => @Platform,
        "BuildID" => @BuildID,
        "AuthCode" => @AuthCode,
        "IssuerID" => "0"
      }
    end

    def request(path, exra_headers = {}, params = {})
      uri = URI.parse(@api_base)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      req = Net::HTTP::Post.new(path, DEFAULT_HEADERS.merge(exra_headers))
      req.set_form_data(params)
      http.request(req)
    end
  end
end