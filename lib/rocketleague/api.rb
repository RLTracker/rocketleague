require "uri"
require "net/http"
require "net/https"

module RocketLeague
  class API
    DEFAULT_HEADERS = {
      "Content-Type" => "application/x-www-form-urlencoded",
      "Environment" => "Prod",
      "User-Agent" => "UE3-TA,UE3Ver(10897)",
      "Cache-Control" => "no-cache"
    }

    def initialize(api_url, build_id, platform, login_secret_key, call_proc_key)
      @api_url = api_url
      @build_id = build_id
      @platform = platform
      @login_secret_key = login_secret_key
      @call_proc_key = call_proc_key
    end

    # returns a Psyonix-Style www-form-urlencoded string
    # which always starts with '&'
    # and keys are not encoded (e.g. contain unencoded '[]')
    def formencode obj
      params = [""]
      obj.each do |key, val|
        if val.kind_of? Array
          val.each do |v|
            params << "#{key}=#{URI.encode_www_form_component(v)}"
          end
        else
          params << "#{key}=#{URI.encode_www_form_component(val)}"
        end
      end
      return params.join("&")
    end

    # creates a Psyonix-Style Proclist body
    #
    # `commands` is an array of arrays where the first item is the Proc name
    # followed by option arguments
    #
    # returns a `formencode` string with 'Proc[]=' function names and 'P#P=' arguments, where '#' is the index of the Proc
    def procencode commands
      payload = {}
      procs = []
      commands.each_with_index do |cmd, i|
        procs << cmd.shift
        payload["P#{i}P"] = cmd
      end
      payload["Proc[]"] = procs
      formencode payload
    end

    # perform a POST request to the Rocket League API
    # with the `DEFAULT_HEADERS` and `extra_headers`
    # SessionID and CallProcKey headers are added unless SessionID is unset
    # returns HTTPResponse
    def request(path, exra_headers = {}, payload)
      uri = URI.parse(@api_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      if @SessionID
        # Used for all requests except initial auth call
        exra_headers.merge!({
          "SessionID" => @SessionID,
          "CallProcKey" => @call_proc_key
        })
      end

      req = Net::HTTP::Post.new(path, DEFAULT_HEADERS.merge(exra_headers))
      req.body = payload
      http.request(req)
    end

    # initiate a new session by authenticating against the API
    # returns boolean whether a SessionID was returned
    def login player_id, player_name, auth_code
      payload = formencode({
        "PlayerName" => player_name,
        "PlayerID" => player_id,
        "Platform" => @platform,
        "BuildID" => @build_id,
        "AuthCode" => auth_code,
        "IssuerID" => 0
      })
      response = request("/auth/", {"LoginSecretKey" => @login_secret_key }, payload)
      return !!(@SessionID = response["sessionid"])
    end
  end
end