# -*- encoding: utf-8 -*-
require 'csv'
require 'zipruby'
require 'gdal-ruby/ogr'
class Gis::Script::Export::Csv


  def self.get_layer_items(layer)
    layer_kind = nil
    items = []
    item = Gis::LayerDatum.new#.readable
    #item.and :layer_id, layer.id
    item.and :layer_id, layer.id
    item.and :state, "enabled"
    item.and :web_state, "public"
    item.order  "updated_at desc"
    items = item.find(:all)
    return {:layer_kind => layer_kind, :items => items}
  end



  def self.export_csv(layer,options={})
    csv_string = export_layer_datum(layer,options)
    return csv_string
  end


  #def self.export_csv( layer)
  def self.export_layer_datum(layer,options={})
    item = Gis::LayerDatum.new#.readable
    #item.and :layer_id, layer.id
    item.and :layer_id, layer.id
    item.and :state, "enabled"
    item.and :web_state, "public"
    item.order  "updated_at desc"
    items = item.find(:all)
    columns_confs = layer.get_column_open_csv
    columns_names = []
    columns_header = []
    columns_confs.each{|val|
      columns_header << val[1]
      columns_names << [val[0], val[1]]
    }
    unless items.blank?
      begin
        csv_string = CSV.generate("", {:encoding => 'sjis',:force_quotes => true}) do |csv|
          csv << columns_header
          items.each do |m|
            record_set = []
            public_photos = m.get_public_photos(10)
            columns_names.each {|column|
              if column[0] =~ /photo/
                if public_photos.blank?
                  record_set << ""
                  next
                end
                photo_count = column[0].gsub(/photo/,"").to_i - 1
                if public_photos[photo_count]
                  record_set << %Q(#{options[:url]}#{public_photos[photo_count].public_photo_path})
                else
                  record_set << ""
                end
              else
                record_set << eval("m.#{column[0]}")
              end

            }
            csv << record_set
          end
        end
        #IE判定
        return  csv_string
      rescue => e
        dump e
        return nil
      end
    end
    return nil
  end

end