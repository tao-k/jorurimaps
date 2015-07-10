class AddBodyToGisAssortments < ActiveRecord::Migration
  def change
    add_column :gis_assortments, :body, :text
    add_column :gis_assortments, :tmp_id, :text
    add_column :gis_assortments, :is_display_message, :integer
  end
end
