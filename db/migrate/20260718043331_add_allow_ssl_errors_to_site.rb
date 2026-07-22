class AddAllowSslErrorsToSite < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :allow_ssl_errors, :boolean
  end
end
