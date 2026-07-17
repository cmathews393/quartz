class AddLevelIdToSite < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :level_id, :string
  end
end
