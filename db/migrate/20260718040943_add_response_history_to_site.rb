class AddResponseHistoryToSite < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :response_history, :text
  end
end
