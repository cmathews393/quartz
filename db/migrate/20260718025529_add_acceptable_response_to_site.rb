class AddAcceptableResponseToSite < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :acceptable_response, :text
  end
end
