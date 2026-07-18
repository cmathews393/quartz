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
      response = Net::HTTP.get_response(URI(site.url))
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
    end
  end

  private

  def level_client
    @level_client ||= ::LevelClient.new
  end
end
