# encoding: utf-8
class Gis::Public::FilesController < Gis::Controller::Public::Base
  include System::Model::FileUtil

  #layout "admin/ud"
  layout "public/gis/template/plain"

  def pre_dispatch
  end

 def layer_file

    item = Gis::Layer.where(:id=>params[:id]).first
    return http_error(404) if item.blank?
    #return http_error(404) unless item.auth_check
    layer_file = item.layer_file
    return http_error(404) if layer_file.blank?
    path = "#{Rails.root.to_s}#{layer_file.file_path}"
    return http_error(404) unless FileTest.exist?(path)
    return http_error(404) if layer_file.file_path =~ /zip/

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = layer_file.original_file_name
    else
      item_filename = layer_file.original_file_name.tosjis
    end

    return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)
  end

  def attach_file
    paths = params[:path].to_s.split(".")
    item = Misc::SocialUpdatePhotos.where(:id => paths[0].to_i).first
    return http_error(404) if item.blank?
    path = "#{Rails.root.to_s}#{item.file_path}"
    return http_error(404) unless FileTest.exist?(path)

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.original_file_name
    else
      item_filename = item.original_file_name.tosjis
    end

    if item.is_image == 1
      return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)
    else
      return send_file(path, :filename => item_filename, :disposition => '  attachment', :x_sendfile => true)
    end
  end

  def map_attach_file
    paths = params[:path].to_s.split(".")
    item = Gis::MapLegendFile.where(:id => paths[0].to_i).first
    return http_error(404) if item.blank?
    path = "#{Rails.root.to_s}#{item.file_path}"
    return http_error(404) unless FileTest.exist?(path)

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.original_file_name
    else
      item_filename = item.original_file_name.tosjis
    end

    if item.is_image == 1
      return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)
    else
      return send_file(path, :filename => item_filename, :disposition => '  attachment', :x_sendfile => true)
    end
  end

  def legend_file
    paths = params[:path].to_s.split(".")
    item = Gis::LegendFile.where(:id => paths[0].to_i).first
    return http_error(404) if item.blank?
    path = "#{Rails.root.to_s}#{item.file_path}"
    return http_error(404) unless FileTest.exist?(path)

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.original_file_name
    else
      item_filename = item.original_file_name.tosjis
    end

    if item.is_image == 1
      return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)
    else
      return send_file(path, :filename => item_filename, :disposition => '  attachment', :x_sendfile => true)
    end
  end

  def thumbnail
    item = Gis::LayerDataPhoto.where(:rid=>params[:id]).first
    return http_error(404) if item.blank?

    return http_error(404) if item.parent.blank?
    if item.thumb_file_path.blank?
      path = "#{Rails.root.to_s}#{item.file_path}"
    else
      path = "#{Rails.root.to_s}#{item.thumb_file_path}"
    end
    return http_error(404) unless FileTest.exist?(path)

    #IE判定
    chk = request.headers['HTTP_USER_AGENT']
    chk = chk.index("MSIE")
    if chk.blank?
      item_filename = item.original_file_name
    else
      item_filename = item.original_file_name.tosjis
    end


    return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)

  end

  def photo
    item = Gis::LayerDataPhoto.where(:rid=>params[:id]).first
    return http_error(404) if item.blank?

    return http_error(404) if item.parent.blank?
    path = "#{Rails.root.to_s}#{item.file_path}"
    return http_error(404) unless FileTest.exist?(path)

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.original_file_name
    else
      item_filename = item.original_file_name.tosjis
    end


    return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)

  end

  def original
    item = Gis::LayerDataPhoto.where(:rid=>params[:id]).first
    return http_error(404) if item.blank?

    return http_error(404) if item.parent.blank?
    path = "#{Rails.root.to_s}#{item.original_file_path}"
    path = "#{Rails.root.to_s}#{item.file_path}" if item.original_file_path.blank? ||  !FileTest.exist?(path)
    return http_error(404) unless FileTest.exist?(path)

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.original_file_name
    else
      item_filename = item.original_file_name.tosjis
    end


    return send_file(path, :filename => item_filename, :disposition => 'inline', :x_sendfile => true)
  end

end
