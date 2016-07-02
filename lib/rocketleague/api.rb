require "uri"
require "net/http"
require "net/https"

module RocketLeague
  class API
    attr_accessor :session_id
    attr_accessor :default_headers

    # initializes the API
    # api_url should be "https://psyonix-rl.appspot.com"
    # build_id changes with every Rocket League update
    # platform is one of "Steam", "PS4", "XboxOne"
    # call_proc_key is usually "pX9pn8F4JnBpoO8Aa219QC6N7g18FJ0F"
    def initialize(api_url, build_id, platform, call_proc_key)
      # default headers sent with every request
      @default_headers = {
        "Content-Type" => "application/x-www-form-urlencoded",
        "Environment" => "Prod",
        "User-Agent" => "UE3-TA,UE3Ver(10897)",
        "Cache-Control" => "no-cache"
      }

      @api_url = api_url
      @build_id = build_id
      @platform = platform
      @call_proc_key = call_proc_key
    end

    # returns a Psyonix-Style www-form-urlencoded string
    # which always starts with '&'
    # and keys are not encoded (e.g. contain unencoded '[]')
    def formencode(obj)
      params = ""
      obj.each do |key, val|
        if val.kind_of? Array
          val.each do |v|
            params += "&#{key}=#{URI.encode_www_form_component(v)}"
          end
        else
          params += "&#{key}=#{URI.encode_www_form_component(val)}"
        end
      end
      params
    end

    # decodes a www-form-urlencoded string
    # returns a key-value Hash, where values are either strings
    # or Array of strings if the key is not unique
    def formdecode(str)
      result = {}
      URI.decode_www_form(str).each do |pair|
        key = pair.first
        val = pair.last
        if result.key? key
          if result[key].kind_of? Array
            result[key] << val
          else
            result[key] = [result[key], val]
          end
        else
          result[key] = val
        end
      end
      result
    end

    # creates a Psyonix-Style Proclist body
    #
    # `commands` is an array of arrays where the first item is the Proc name
    # followed by option arguments
    #
    # returns a `formencode` string with 'Proc[]=' function names and 'P#P=' arguments, where '#' is the index of the Proc
    def procencode(commands)
      payload = {}
      procs = []
      commands.each_with_index do |cmd, i|
        procs << cmd.shift
        payload["P#{i}P[]"] = cmd
      end
      payload["Proc[]"] = procs
      formencode payload
    end

    # parses the response to a Proc request
    # returns an Array of results, which should be analogue to the `procencode` command order.
    # each result is an Array of `formdecode` Hashes and/or RuntimeErrors
    def procparse(response)
      results = []
      # remove trailing empty line
      response.gsub! /\r?\n\z/, ''
      # split on empty lines
      # may be first, intermediate, or last line
      # may be using CRLF or LF
      # Psyonix ¯\_(ツ)_/¯
      parts = response.split(/^\r?$\n|\r?\n\r?\n|\r?$\n$/, -1)
      parts.each do |part|
        result = []
        lines = part.split /\r?\n/, -1
        lines.each do |line|
          # PROCEDURE ERROR = Function does not exist
          # SCRIPT ERROR    = Function parameters missing or invalid
          # SQL ERROR       = Data not available
          if line =~ /^(PROCEDURE|SCRIPT|SQL) ERROR/
            # Can be on a single line while others are fine
            # We don't want to raise an exception cause 1 line failed
            result << RuntimeError.new(line)
          else
            result << formdecode(line)
          end
        end
        results << result
      end
      results
    end

    # performs a POST request to the Rocket League API
    # with the `default_headers` and `extra_headers`
    # SessionID and CallProcKey headers are added unless SessionID is unset
    # returns HTTPResponse
    def request(path,exra_headers = {}, payload)
      uri = URI.parse(@api_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      if @session_id
        # Used for all requests except initial auth call
        exra_headers.merge!({
          "SessionID" => @session_id,
          "CallProcKey" => @call_proc_key
        })
      end

      req = Net::HTTP::Post.new(path, @default_headers.merge(exra_headers))
      req.body = payload
      http.request(req)
    end

    # initiates a new session by authenticating against the API
    # login_secret_key is usually "dUe3SE4YsR8B0c30E6r7F2KqpZSbGiVx"
    # returns boolean whether a SessionID was received
    def login(player_id, player_name, auth_code, auth_ticket, login_secret_key)
      payload = formencode({
        "PlayerName" => player_name,
        "PlayerID" => player_id,
        "Platform" => @platform,
        "BuildID" => @build_id,
        "AuthCode" => auth_code,
        "AuthTicket" => auth_ticket,
        "IssuerID" => 0
      })
      response = request("/auth/", {"LoginSecretKey" => login_secret_key }, payload)
      !!(@session_id = response["sessionid"])
    end
  end
end
