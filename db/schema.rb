# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140320101510) do

  create_table "cms_kana_dictionaries", :force => true do |t|
    t.integer  "unid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "body"
    t.text     "ipadic_body"
    t.text     "unidic_body"
    t.datetime "deleted_at"
    t.text     "created_user"
    t.text     "created_group"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end


  create_table "cms_portal_photos", :force => true do |t|
    t.integer  "unid"
    t.integer  "site_id"
    t.text     "web_state"
    t.text     "category"
    t.text     "title"
    t.text     "caption"
    t.text     "original_file_name"
    t.text     "file_path"
    t.text     "file_uri"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "sort_no"
  end


  create_table "gis_assortments", :force => true do |t|
    t.text     "title"
    t.integer  "sort_no"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.datetime "created_at",     :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",     :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.text     "web_state"
  end

  create_table "gis_assortments_layers", :primary_key => "rid", :force => true do |t|
    t.integer  "assortment_id"
    t.integer  "layer_id"
    t.integer  "sort_no"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "layer_order"
  end

  create_table "gis_background_maps", :force => true do |t|
    t.string   "state",         :limit => 10
    t.string   "code"
    t.string   "title"
    t.string   "kind"
    t.text     "url"
    t.integer  "sort_no"
    t.datetime "created_at",                  :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                  :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end


  create_table "gis_layer_data", :primary_key => "rid", :force => true do |t|
    t.integer  "layer_id"
    t.string   "area_code"
    t.string   "state",         :limit => 10
    t.string   "web_state",     :limit => 10
    t.text     "name"
    t.text     "caption"
    t.string   "icon_kind"
    t.integer  "icon_id"
    t.text     "address"
    t.float    "lat"
    t.float    "lng"
    t.text     "genre_ids"
    t.text     "input_fld_1"
    t.text     "input_fld_2"
    t.text     "input_fld_3"
    t.text     "input_fld_4"
    t.text     "input_fld_5"
    t.text     "input_fld_6"
    t.text     "input_fld_7"
    t.text     "input_fld_8"
    t.text     "input_fld_9"
    t.text     "input_fld_10"
    t.text     "input_fld_11"
    t.text     "input_fld_12"
    t.text     "input_fld_13"
    t.text     "input_fld_14"
    t.text     "input_fld_15"
    t.text     "input_fld_16"
    t.text     "input_fld_17"
    t.text     "input_fld_18"
    t.text     "input_fld_19"
    t.text     "input_fld_20"
    t.text     "input_fld_21"
    t.text     "input_fld_22"
    t.text     "input_fld_23"
    t.text     "input_fld_24"
    t.text     "input_fld_25"
    t.text     "input_fld_26"
    t.text     "input_fld_27"
    t.text     "input_fld_28"
    t.text     "input_fld_29"
    t.text     "input_fld_30"
    t.text     "input_fld_31"
    t.text     "input_fld_32"
    t.text     "input_fld_33"
    t.text     "input_fld_34"
    t.text     "input_fld_35"
    t.text     "input_fld_36"
    t.text     "input_fld_37"
    t.text     "input_fld_38"
    t.text     "input_fld_39"
    t.text     "input_fld_40"
    t.text     "input_fld_41"
    t.text     "input_fld_42"
    t.text     "input_fld_43"
    t.text     "input_fld_44"
    t.text     "input_fld_45"
    t.text     "input_fld_46"
    t.text     "input_fld_47"
    t.text     "input_fld_48"
    t.text     "input_fld_49"
    t.text     "input_fld_50"
    t.datetime "created_at",                                             :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                                             :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"geometry"}
  end

  execute "ALTER TABLE gis_layer_data SET WITH OIDS ;"

  create_table "gis_layer_data_columns", :force => true do |t|
    t.integer  "layer_id"
    t.text     "input_fld_1"
    t.text     "input_fld_2"
    t.text     "input_fld_3"
    t.text     "input_fld_4"
    t.text     "input_fld_5"
    t.text     "input_fld_6"
    t.text     "input_fld_7"
    t.text     "input_fld_8"
    t.text     "input_fld_9"
    t.text     "input_fld_10"
    t.text     "input_fld_11"
    t.text     "input_fld_12"
    t.text     "input_fld_13"
    t.text     "input_fld_14"
    t.text     "input_fld_15"
    t.text     "input_fld_16"
    t.text     "input_fld_17"
    t.text     "input_fld_18"
    t.text     "input_fld_19"
    t.text     "input_fld_20"
    t.text     "input_fld_21"
    t.text     "input_fld_22"
    t.text     "input_fld_23"
    t.text     "input_fld_24"
    t.text     "input_fld_25"
    t.text     "input_fld_26"
    t.text     "input_fld_27"
    t.text     "input_fld_28"
    t.text     "input_fld_29"
    t.text     "input_fld_30"
    t.text     "input_fld_31"
    t.text     "input_fld_32"
    t.text     "input_fld_33"
    t.text     "input_fld_34"
    t.text     "input_fld_35"
    t.text     "input_fld_36"
    t.text     "input_fld_37"
    t.text     "input_fld_38"
    t.text     "input_fld_39"
    t.text     "input_fld_40"
    t.text     "input_fld_41"
    t.text     "input_fld_42"
    t.text     "input_fld_43"
    t.text     "input_fld_44"
    t.text     "input_fld_45"
    t.text     "input_fld_46"
    t.text     "input_fld_47"
    t.text     "input_fld_48"
    t.text     "input_fld_49"
    t.text     "input_fld_50"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.text     "show_fld"
  end

  create_table "gis_layer_data_photos", :primary_key => "rid", :force => true do |t|
    t.integer  "layer_id"
    t.integer  "layer_data_id"
    t.string   "web_state",          :limit => 10
    t.integer  "sort_no"
    t.text     "caption"
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "original_file_name"
    t.text     "compass_point"
    t.integer  "rotation"
    t.text     "content_type"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",                                                  :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                                                  :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.spatial  "g",                  :limit => {:srid=>4326, :type=>"geometry"}
    t.text     "thumb_file_path"
    t.text     "thumb_file_uri"
    t.text     "original_file_path"
    t.text     "original_file_uri"
  end

  create_table "gis_layer_draw_configs", :force => true do |t|
    t.integer  "layer_id"
    t.integer  "mapfile_id"
    t.text     "geometry_type"
    t.text     "label_column"
    t.text     "label_color"
    t.text     "point_color"
    t.text     "line_color"
    t.text     "line_width"
    t.text     "polygon_color"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_layer_files", :force => true do |t|
    t.integer  "layer_id"
    t.text     "kind"
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "original_file_name"
    t.text     "content_type"
    t.text     "state"
    t.text     "title"
    t.text     "caption"
    t.integer  "sort_no"
    t.datetime "created_at",         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "srid"
  end

  create_table "gis_layer_import_configs", :force => true do |t|
    t.integer  "layer_id"
    t.text     "layer_code"
    t.text     "table_name"
    t.text     "filter"
    t.text     "title_column"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_layer_import_data", :primary_key => "rid", :force => true do |t|
    t.integer  "layer_id"
    t.string   "area_code"
    t.string   "state",         :limit => 10
    t.string   "web_state",     :limit => 10
    t.text     "lat"
    t.text     "lng"
    t.text     "input_fld_1"
    t.text     "input_fld_2"
    t.text     "input_fld_3"
    t.text     "input_fld_4"
    t.text     "input_fld_5"
    t.text     "input_fld_6"
    t.text     "input_fld_7"
    t.text     "input_fld_8"
    t.text     "input_fld_9"
    t.text     "input_fld_10"
    t.text     "input_fld_11"
    t.text     "input_fld_12"
    t.text     "input_fld_13"
    t.text     "input_fld_14"
    t.text     "input_fld_15"
    t.text     "input_fld_16"
    t.text     "input_fld_17"
    t.text     "input_fld_18"
    t.text     "input_fld_19"
    t.text     "input_fld_20"
    t.text     "input_fld_21"
    t.text     "input_fld_22"
    t.text     "input_fld_23"
    t.text     "input_fld_24"
    t.text     "input_fld_25"
    t.text     "input_fld_26"
    t.text     "input_fld_27"
    t.text     "input_fld_28"
    t.text     "input_fld_29"
    t.text     "input_fld_30"
    t.text     "input_fld_31"
    t.text     "input_fld_32"
    t.text     "input_fld_33"
    t.text     "input_fld_34"
    t.text     "input_fld_35"
    t.text     "input_fld_36"
    t.text     "input_fld_37"
    t.text     "input_fld_38"
    t.text     "input_fld_39"
    t.text     "input_fld_40"
    t.text     "input_fld_41"
    t.text     "input_fld_42"
    t.text     "input_fld_43"
    t.text     "input_fld_44"
    t.text     "input_fld_45"
    t.text     "input_fld_46"
    t.text     "input_fld_47"
    t.text     "input_fld_48"
    t.text     "input_fld_49"
    t.text     "input_fld_50"
    t.datetime "created_at",                                                :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                                                :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"geometry"}
  end

  execute "ALTER TABLE gis_layer_import_data SET WITH OIDS ;"

  create_table "gis_layer_public_informations", :force => true do |t|
    t.integer  "layer_id"
    t.integer  "public_kind"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_layers", :force => true do |t|
    t.string   "state",               :limit => 10
    t.string   "public_state",        :limit => 10
    t.string   "code"
    t.string   "title"
    t.string   "kind"
    t.integer  "is_internal"
    t.text     "url"
    t.integer  "mapfile_id"
    t.text     "mapfile_layer_name"
    t.float    "opacity"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.datetime "created_at",                        :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                        :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.text     "layer_legend"
    t.text     "tmp_id"
    t.integer  "csv_export"
    t.integer  "kml_export"
    t.integer  "shp_export"
    t.integer  "kml_export_no_label"
    t.integer  "is_slideshow"
    t.integer  "srid"
  end

  create_table "gis_layers_managers", :primary_key => "rid", :force => true do |t|
    t.integer  "layer_id"
    t.integer  "group_id"
    t.string   "role_kind",     :limit => 10
    t.datetime "created_at",                  :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                  :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_legend_files", :force => true do |t|
    t.integer  "layer_id"
    t.integer  "ledend_id"
    t.text     "tmp_id"
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "original_file_name"
    t.text     "content_type"
    t.integer  "is_image"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.datetime "created_at",         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_location_points", :primary_key => "rid", :force => true do |t|
    t.string   "location_kind", :limit => 10
    t.text     "pref_code"
    t.text     "pref_name"
    t.text     "city_code"
    t.text     "city_name"
    t.text     "lot_code"
    t.text     "lot_name"
    t.text     "lot_kind_name"
    t.text     "block_code"
    t.text     "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",                                                :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                                                :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"geometry"}
  end

  add_index "gis_location_points", ["address"], :name => "location_address"
  add_index "gis_location_points", ["city_name"], :name => "location_city_name"
  add_index "gis_location_points", ["lot_code"], :name => "location_lot_code"
  add_index "gis_location_points", ["lot_name"], :name => "location_lot_name"
  add_index "gis_location_points", ["pref_name"], :name => "location_pref_name"

  create_table "gis_map_configs", :force => true do |t|
    t.integer  "portal_id"
    t.text     "lat"
    t.text     "lng"
    t.integer  "zoom"
    t.text     "base_layer"
    t.text     "layers"
    t.text     "options"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_map_icons", :force => true do |t|
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "original_file_name"
    t.text     "content_type"
    t.text     "state"
    t.string   "title"
    t.text     "caption"
    t.integer  "sort_no"
    t.integer  "width"
    t.integer  "height"
    t.integer  "position_offset"
    t.datetime "created_at",         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_map_legend_files", :force => true do |t|
    t.integer  "map_id"
    t.integer  "ledend_id"
    t.text     "tmp_id"
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "original_file_name"
    t.text     "content_type"
    t.integer  "is_image"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.datetime "created_at",         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_mapfile_histories", :force => true do |t|
    t.integer  "mapfile_id"
    t.text     "file_name"
    t.text     "file_directory"
    t.text     "file_path"
    t.string   "state",             :limit => 10
    t.string   "title"
    t.text     "caption"
    t.text     "body"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.text     "created_group"
    t.datetime "updated_at",                      :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.datetime "created_at",                      :null => false
    t.text     "created_user"
    t.integer  "is_vector_mapfile"
  end

  create_table "gis_mapfiles", :force => true do |t|
    t.text     "file_name"
    t.text     "file_directory"
    t.text     "file_path"
    t.string   "state",             :limit => 10
    t.string   "title"
    t.text     "caption"
    t.text     "body"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.text     "created_group"
    t.datetime "updated_at",                      :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.datetime "created_at",                      :null => false
    t.text     "created_user"
    t.integer  "is_vector_mapfile"
  end

  create_table "gis_maps", :force => true do |t|
    t.string   "state",                :limit => 10
    t.string   "web_state",            :limit => 10
    t.string   "code"
    t.string   "title"
    t.text     "message"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.text     "in_genre_id"
    t.datetime "created_at",                         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "sort_no"
    t.text     "map_legend"
    t.text     "tmp_id"
    t.integer  "portal_kind"
    t.text     "body"
    t.text     "link_url"
    t.text     "icon_path"
    t.text     "icon_uri"
    t.text     "parent_category_id"
    t.text     "category_id"
    t.text     "thumb_path"
    t.text     "thumb_uri"
    t.text     "parent_category_id_1"
    t.text     "parent_category_id_2"
    t.integer  "is_display_message"
    t.integer  "is_recommend"
  end

  create_table "gis_maps_assortments", :primary_key => "rid", :force => true do |t|
    t.integer  "map_id"
    t.integer  "assortment_id"
    t.integer  "sort_no"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "gis_maps_layers", :primary_key => "rid", :force => true do |t|
    t.integer  "map_id"
    t.integer  "layer_id"
    t.integer  "sort_no"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "layer_order"
  end

  create_table "gis_maps_recognizers", :primary_key => "rid", :force => true do |t|
    t.integer  "portal_id"
    t.integer  "user_id"
    t.text     "code"
    t.text     "name"
    t.datetime "recognized_at"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_feed_histories", :force => true do |t|
    t.datetime "requested_at"
    t.integer  "count"
    t.string   "publisher_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "misc_feed_items", :force => true do |t|
    t.text     "title"
    t.datetime "published_at"
    t.text     "author"
    t.string   "genre01"
    t.string   "genre02"
    t.string   "genre03"
    t.text     "url"
    t.integer  "feed_history_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "misc_feed_items", ["feed_history_id"], :name => "index_misc_feed_items_on_feed_history_id"

  create_table "misc_inquiries", :force => true do |t|
    t.integer  "portal_id"
    t.integer  "sort_no"
    t.text     "mail_to"
    t.text     "tel"
    t.text     "fax"
    t.text     "charge"
    t.integer  "inquiry_group_id"
    t.datetime "created_at",       :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",       :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_portal_links", :force => true do |t|
    t.integer  "portal_id"
    t.text     "title"
    t.text     "url"
    t.integer  "sort_no"
    t.string   "web_state",     :limit => 10
    t.datetime "created_at",                  :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                  :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_portal_photos", :force => true do |t|
    t.integer  "portal_id"
    t.integer  "sort_no"
    t.string   "web_state",          :limit => 10
    t.text     "title"
    t.text     "caption"
    t.text     "original_file_name"
    t.text     "file_path"
    t.text     "file_uri"
    t.datetime "created_at",                       :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                       :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_portal_recommends", :force => true do |t|
    t.integer  "portal_id"
    t.string   "web_state",     :limit => 10
    t.string   "title"
    t.integer  "sort_no"
    t.text     "url"
    t.text     "name"
    t.text     "column_flds"
    t.text     "area_code"
    t.datetime "created_at",                  :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                  :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_search_columns", :force => true do |t|
    t.integer  "portal_id"
    t.text     "column_flds"
    t.text     "label"
    t.text     "form_type"
    t.integer  "sort_no"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_search_selects", :force => true do |t|
    t.integer  "portal_id"
    t.integer  "config_id"
    t.text     "selects"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_social_update_photos", :force => true do |t|
    t.text     "tmp_id"
    t.integer  "parent_id"
    t.text     "model_name"
    t.integer  "size"
    t.integer  "is_image"
    t.text     "original_file_name"
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "content_type"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "misc_social_updates", :force => true do |t|
    t.integer  "map_id"
    t.string   "web_state",        :limit => 10
    t.text     "title"
    t.text     "body"
    t.datetime "published_at"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.datetime "created_at",                     :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                     :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "inquiry_group_id"
    t.text     "mail_to"
    t.text     "tel"
    t.text     "fax"
    t.text     "charge"
    t.text     "tmp_id"
    t.text     "name"
  end

  create_table "misc_tweets", :force => true do |t|
    t.string   "body"
    t.datetime "tweeting_at"
    t.datetime "tweeted_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sys_messages", :force => true do |t|
    t.integer  "unid"
    t.string   "state",         :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
    t.datetime "deleted_at"
    t.text     "created_user"
    t.text     "created_group"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "system_admin_logs", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "item_unid"
    t.text     "controller"
    t.text     "action"
  end

  create_table "system_cities", :id => false, :force => true do |t|
    t.string   "rid"
    t.string   "pref_id"
    t.string   "name"
    t.string   "code"
    t.integer  "sort_no"
    t.string   "lat"
    t.string   "lng"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"point"}
    t.text     "zone_rid"
    t.string   "county_id"
    t.string   "county_rid"
    t.string   "icon_class"
  end


  create_table "system_counties", :id => false, :force => true do |t|
    t.string   "rid"
    t.string   "pref_id"
    t.string   "zone_id"
    t.string   "name"
    t.string   "code"
    t.integer  "sort_no"
    t.string   "lat"
    t.string   "lng"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"point"}
    t.string   "kind"
  end

  create_table "system_creators", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unid"
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
  end


  create_table "system_group_change_dates", :force => true do |t|
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.datetime "start_at"
  end

  create_table "system_group_changes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "level_no"
    t.string   "parent_code"
    t.string   "parent_name"
    t.string   "change_division"
    t.integer  "ldap"
    t.datetime "start_date"
    t.string   "old_division"
    t.integer  "old_id"
    t.string   "old_code"
    t.string   "old_name"
    t.string   "commutation_code"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "system_groups", :force => true do |t|
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
    t.datetime "deleted_at"
  end

  create_table "system_ldap_temporaries", :force => true do |t|
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
    t.string   "data_type"
    t.string   "code"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "kana"
    t.text     "email"
    t.text     "match"
    t.string   "official_position"
    t.string   "assigned_job"
  end

  create_table "system_link_banners", :force => true do |t|
    t.text     "title"
    t.text     "url"
    t.integer  "sort_no"
    t.string   "web_state",            :limit => 10
    t.text     "parent_category_id_0"
    t.text     "parent_category_id_1"
    t.text     "parent_category_id_2"
    t.text     "tmp_id"
    t.text     "original_file_name"
    t.text     "file_path"
    t.text     "file_uri"
    t.text     "content_type"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "system_login_logs", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_messages", :force => true do |t|
    t.integer  "unid"
    t.string   "state",         :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "title"
    t.text     "body"
    t.datetime "deleted_at"
    t.text     "created_user"
    t.text     "created_group"
    t.text     "updated_user"
    t.text     "updated_group"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "system_options", :force => true do |t|
    t.string   "kind",          :limit => 50
    t.text     "value"
    t.datetime "created_at",                  :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                  :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "system_prefs", :id => false, :force => true do |t|
    t.string   "rid"
    t.string   "name"
    t.string   "code"
    t.integer  "sort_no"
    t.string   "lat"
    t.string   "lng"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"point"}
  end

  create_table "system_priv_names", :force => true do |t|
    t.integer  "unid"
    t.text     "state"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name"
    t.text     "priv_name"
    t.integer  "sort_no"
  end

  create_table "system_related_links", :force => true do |t|
    t.text     "title"
    t.text     "url"
    t.integer  "sort_no"
    t.string   "web_state",            :limit => 10
    t.text     "parent_category_id_0"
    t.text     "parent_category_id_1"
    t.text     "parent_category_id_2"
    t.datetime "created_at",                         :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                         :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "system_role_name_privs", :force => true do |t|
    t.integer  "role_id"
    t.integer  "priv_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_role_names", :force => true do |t|
    t.integer  "unid"
    t.text     "state"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name"
    t.text     "table_name"
    t.integer  "sort_no"
  end

  create_table "system_roles", :force => true do |t|
    t.string   "table_name"
    t.string   "priv_name"
    t.integer  "idx"
    t.integer  "class_id"
    t.integer  "uid"
    t.integer  "priv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id"
    t.integer  "priv_user_id"
    t.integer  "group_id"
  end

  create_table "system_sequences", :force => true do |t|
    t.string   "name"
    t.integer  "version"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "system_short_messages", :force => true do |t|
    t.integer  "sort_no"
    t.text     "body"
    t.datetime "release_at"
    t.datetime "end_at"
    t.datetime "created_at",    :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",    :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
  end

  create_table "system_social_updates", :force => true do |t|
    t.integer  "map_id"
    t.integer  "is_tweet"
    t.integer  "tweet_id"
    t.string   "web_state",        :limit => 10
    t.text     "title"
    t.text     "body"
    t.datetime "published_at"
    t.integer  "user_kind"
    t.integer  "admin_user_id"
    t.integer  "admin_group_id"
    t.datetime "created_at",                     :null => false
    t.text     "created_user"
    t.text     "created_group"
    t.datetime "updated_at",                     :null => false
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "deleted_at"
    t.text     "deleted_user"
    t.text     "deleted_group"
    t.integer  "inquiry_group_id"
    t.text     "mail_to"
    t.text     "tel"
    t.text     "fax"
    t.text     "charge"
    t.text     "tmp_id"
    t.text     "name"
  end

  create_table "system_users", :force => true do |t|
    t.string   "air_login_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      :null => false
    t.integer  "ldap",                      :null => false
    t.integer  "ldap_version"
    t.integer  "auth_no"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "kana"
    t.text     "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.text     "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "air_token"
    t.text     "account"
  end

  create_table "system_users_groups", :primary_key => "rid", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_groups_csvdata", :force => true do |t|
    t.string   "state",             :null => false
    t.string   "data_type",         :null => false
    t.integer  "level_no"
    t.integer  "parent_id",         :null => false
    t.string   "parent_code",       :null => false
    t.string   "code",              :null => false
    t.integer  "sort_no"
    t.integer  "ldap",              :null => false
    t.integer  "job_order"
    t.text     "name",              :null => false
    t.text     "name_en"
    t.text     "kana"
    t.string   "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.string   "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.integer  "auth_no"
    t.datetime "start_at",          :null => false
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_zones", :id => false, :force => true do |t|
    t.string   "rid"
    t.string   "pref_id"
    t.string   "name"
    t.string   "code"
    t.integer  "sort_no"
    t.string   "lat"
    t.string   "lng"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.spatial  "g",             :limit => {:srid=>4326, :type=>"point"}
  end


end
