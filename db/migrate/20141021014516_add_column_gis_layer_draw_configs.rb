class AddColumnGisLayerDrawConfigs < ActiveRecord::Migration
  def up
    add_column :gis_layer_draw_configs, :label_position, :string, :limit => 50
    add_column :gis_layer_draw_configs, :point_fill, :integer
    add_column :gis_layer_draw_configs, :line_fill, :integer
    add_column :gis_layer_draw_configs, :polygon_fill, :integer
    add_column :gis_layer_draw_configs, :label_size, :integer
    Gis::LayerDrawConfig.update_all(:label_position => "auto")
    Gis::LayerDrawConfig.update_all(:label_size => 8)
  end

  def down
    remove_column :gis_layer_draw_configs, :label_position
    remove_column :gis_layer_draw_configs, :point_fill
    remove_column :gis_layer_draw_configs, :line_fill
    remove_column :gis_layer_draw_configs, :polygon_fill
    remove_column :gis_layer_draw_configs, :label_size
  end
end
