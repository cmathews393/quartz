class Api::V1::SitesApiController < ::ApplicationController
  include SitesHelper
  before_action :set_site, only: %i[show update destroy status_stream level_status_stream]
  def index
    @sites = Site.all
    render json: @sites
  end

  def show
    render json: @site
  end

  def create
    @site = Site.new(site_params)
    if @site.save
      render json: @site, status: :created
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  def update
    if @site.update(site_params)
      render json: @site, status: :ok
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @site.destroy
    head :no_content
  end

  # GET /api/v1/sites/:id/status_stream
  def status_stream
    loop_for_sse(-> { reachable(@site) }, :result, "sites/reachable_status")
  end

  def level_status_stream
    loop_for_sse(-> { level_reachable(@site) }, :level_result, "sites/level_status")
  end


private
  def set_site
    @site = Site.find(params[:id])
  end

  def loop_for_sse(function, variable_name, partial)
    datastar = Datastar.from_rack_env(request.env, view_context: view_context)
    datastar.stream do |sse|
      old_result = nil
      loop do
        result = function.call
        if old_result != result
          sse.patch_elements(render_to_string(partial: partial, locals: { site: @site, variable_name => result }))
        end
        old_result = result
        sleep 5
      end
    end
  end

  def site_params
    params.require(:site).permit(:name, :url, :level_id, :allow_ssl_errors)
  end
end
