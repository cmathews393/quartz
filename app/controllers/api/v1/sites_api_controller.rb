class Api::V1::SitesApiController < ::ApplicationController
  include SitesHelper
  before_action :set_site, only: %i[show update destroy status_stream]
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
    datastar = Datastar.from_rack_env(request.env, view_context: view_context)

    datastar.stream do |sse|
      loop do
        result = reachable(@site)
        sse.patch_elements(render_to_string(partial: "sites/status", locals: { site: @site, result: result }))
        sleep 5
      end
    end
  end


  private

  def set_site
    @site = Site.find(params[:id])
  end

  def site_params
    params.require(:site).permit(:name, :url, :level_id, :allow_ssl_errors)
  end
end
