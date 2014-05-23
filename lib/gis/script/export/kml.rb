# -*- encoding: utf-8 -*-
require 'csv'
require 'zipruby'
require 'gdal-ruby/ogr'
class Gis::Script::Export::Kml



  def self.get_export_option(layer,options)
    options[:imported] = true if layer.kind == "file"
    return options
  end

  def self.export_kml(layer,options={})
    options = get_export_option(layer,options)
    if options[:imported]
      xml_obj = export_imported_data(layer, options)
    else
      xml_obj = export_layer_datum(layer, options)
    end
    return xml_obj
  end


  def self.map_icon_uri(item, options={})
    ret = ""
    ret += options[:url] if options[:url]
    if !item.blank? && item.file_path && item.file_uri
      ret +=  item.file_uri
    else
      ret +=  "/_common/themes/gis/images/marker.png"
    end
    return ret
  end



  def self.geom_kml_content(item, column_names)
    result_html = "<![CDATA["
    column_names.each do |column|
      next if column == "geom"
      result_html +=  "#{column}："
      result_html +=  eval("item.#{column}.to_s")
      result_html += "<br />"
    end
    result_html += "]]>"
    return result_html
  end


  def self.export_imported_data(layer, options={})
    items = Gis::LayerImportDatum.find(:all, :select => ["gis_layer_data.*, ST_AsKML(g) as geom_kml"],
     :conditions=>["layer_id = ? and web_state = ? and g IS NOT NULL", layer.id, "public"])

    return if items.blank?
    xml = Builder::XmlMarkup.new :indent => 2
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml_obj = xml.kml('xmlns' => 'http://earth.google.com/kml/2.2'){
      xml.Document{
        xml.name("#{layer.title}")
        xml.description("#{layer.title}のデータ")

        items.each do |item|
          xml.Placemark{
            xml.name(item.name)
             xml.description{
                xml << item.kml_content
              }
            xml.Style('id' => 'style1'){
            case item.g.to_s
            when /POINT/
              xml.IconStyle{
                xml.Icon{
                  xml.href("/_common/themes/ud/images/red-dot.png")
                }
              }
            else
              xml.LineStyle{
                xml.color("73FF0000")
                xml.width("5")
              }
              xml.PolyStyle{
                xml.color("73FF0000")
              }
            end
            if options[:no_label]
                xml.LabelStyle{
                  xml.scale("0")
                }
              end
            }
            xml << %Q(      #{item.geom_kml}\n)
          }
        end
      }
    }
    return xml_obj
  end



  def self.export_layer_datum(layer,options={})
    items = Gis::LayerDatum.find(:all, :select => ["gis_layer_data.*, ST_AsKML(g) as geom_kml"],
     :conditions=>["layer_id = ? and web_state = ? and g IS NOT NULL", layer.id, "public"])

    return if items.blank?
    xml = Builder::XmlMarkup.new :indent => 2
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml_obj = xml.kml('xmlns' => 'http://earth.google.com/kml/2.2'){
      xml.Document{
        xml.name("#{layer.title}")
        xml.description("#{layer.title}のデータ")

        items.each do |item|
          xml.Placemark{
            xml.name(item.name)
             xml.description{
                xml << item.kml_content
              }
            xml.Style('id' => 'style1'){
            case item.g.to_s
            when /POINT/
              xml.IconStyle{
                xml.Icon{
                  xml.href(map_icon_uri(item.icon, options))
                }
              }
            else
              xml.LineStyle{
                xml.color("73FF0000")
                xml.width("5")
              }
              xml.PolyStyle{
                xml.color("73FF0000")
              }
            end
            if options[:no_label]
                xml.LabelStyle{
                  xml.scale("0")
                }
              end
            }
            xml << %Q(      #{item.geom_kml}\n)
          }
        end
      }
    }
    return xml_obj
  end


end