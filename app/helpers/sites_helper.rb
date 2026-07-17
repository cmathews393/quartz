module SitesHelper
  def device_for_site(site)
    level_client.get_device(site.level_id)
  end

  private

  def level_client
    @level_client ||= ::LevelClient.new
  end
end
