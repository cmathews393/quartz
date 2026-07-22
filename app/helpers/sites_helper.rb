require "net/http"
module SitesHelper
  def device_for_site(site)
    return unless ENV["LEVEL_API_KEY"] && site.level_id

    begin
      level_client.get_device(site.level_id)["online"]
    rescue
      nil
    end
  end

  def reachable(site)
    begin
      uri = URI(site.url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", verify_mode: (site.allow_ssl_errors && uri.scheme == "https" ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER)) do |http|
        http.get(uri.request_uri)
      end
      if site.acceptable_response.present?
        acceptable_codes = site.acceptable_response.is_a?(Array) ? site.acceptable_response : site.acceptable_response.split(",")
        acceptable_codes = acceptable_codes.map(&:to_s).map(&:strip)
      else
        acceptable_codes = [ "200" ]
      end

      { ok: acceptable_codes.include?(response.code), code: response.code }
    rescue Errno::ECONNREFUSED
      { ok: false, error: "connection_refused" }
    rescue Errno::EHOSTUNREACH
      { ok: false, error: "host_unreachable" }
    rescue Timeout::Error
      { ok: false, error: "timeout" }
    rescue Socket::ResolutionError
      { ok: false, error: "unresolved_addr" }
    rescue OpenSSL::SSL::SSLError
      { ok: false, error: "ssl_error" }
    end
  end

  private

  def level_client
    @level_client ||= ::LevelClient.new
  end
end
