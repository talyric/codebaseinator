require 'json'
require 'net/http'

class CodebaseApi

  def self.api_username
    Rails.configuration.database_configuration[Rails.env]['codebase_api_username']
  end

  def self.api_key
    Rails.configuration.database_configuration[Rails.env]['codebase_api_key']
  end

  def self.request(path, type = :get, payload = nil)
    puts type.inspect
    if type == :get
      req = Net::HTTP::Get.new(path)
    elsif type == :post
      req = Net::HTTP::Post.new(path)
    end

    req.basic_auth(api_username, api_key)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'

    if payload && payload.respond_to?(:to_json)
      req.body = payload.to_json
      puts req.body
    end


    if ENV["DEVELOPMENT"]
      res = Net::HTTP.new("api3.codebase.dev", 80)
    else
      res = Net::HTTP.new("api3.codebasehq.com", 443)
      res.use_ssl = true
      res.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    process_request(res, req)
  end

  def self.process_request(res, req)
    puts "Requesting #{req.path}"
    case result = res.request(req)
      when Net::HTTPSuccess
        #json decode
        return JSON.parse(result.body)
      else
        puts result
        puts "Sorry, that request failed."
        puts result.body
        return false
    end
  end

end