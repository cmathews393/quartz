class SitesController < ApplicationController
  before_action :set_site, only: %i[show edit update destroy]
  def index
    @sites = Site.all
  end

  def show
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)
    if @site.save
      redirect_to sites_path
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit
  end
  def update
    if @site.update(site_params)
      redirect_to sites_path
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @site.destroy
    redirect_to sites_path
  end
  private
    def set_site
      @site = Site.find(params[:id])
    end
    def site_params
      params.expect(site: [ :name, :url, :level_id, :allow_ssl_errors ])
    end
end
