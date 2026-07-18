require "net/http"
require "json"

class LevelClient
  BASE_URL = ENV.fetch("LEVEL_API_URL", "https://api.level.io/v2")
  API_KEY = ENV.fetch("LEVEL_API_KEY", nil)

  def initialize
    @base_url = BASE_URL
    @api_key = API_KEY
  end

  def get_device(device_id)
    method = :get
    path = "/devices/#{device_id}"
    request(method, path)
  end

  def get_devices
    method = :get
    path = "/devices/"
    response = request(method, path)
    # unwrap data safely
    response.dig("data")
  end

  private

  def request(method, path, body: nil)
    uri = URI("#{@base_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    request_obj = case method
    when :get
      Net::HTTP::Get.new(uri)
    when :post
      Net::HTTP::Post.new(uri)
    when :put
      Net::HTTP::Put.new(uri)
    when :delete
      Net::HTTP::Delete.new(uri)
    else
      raise "Unsupported HTTP method: #{method}"
    end

    request_obj["Content-Type"] = "application/json"
    request_obj["Authorization"] = @api_key if @api_key
    request_obj.body = body.to_json if body

    response = http.request(request_obj)
    handle_response(response)
  end

  def handle_response(response)
    case response.code.to_i
    when 200..299
      JSON.parse(response.body) if response.body.present?
    when 400
      raise "Bad Request: #{response.body}"
    when 401
      raise "Unauthorized: Invalid API key"
    when 404
      raise "Not Found: #{response.body}"
    when 429
      raise "Rate Limited: Please retry later"
    when 500..599
      raise "Server Error: #{response.code} - #{response.body}"
    else
      raise "Unexpected response: #{response.code}"
    end
  end
end
