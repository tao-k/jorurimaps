class AddGeometryTypeToGisLayers < ActiveRecord::Migration

  def change
    add_column :gis_layers, :geometry_type, :string, :limit => 50
  end
end
