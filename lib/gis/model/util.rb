# encoding: utf-8
module Gis::Model::Util
  def get_uname(options={})
    case
    when !options[:uid].nil?
      ux = System::User.find(:first, :conditions=>"id=#{options[:uid]}")
      return '' if ux.nil?
      return Gis.trim(nz(ux.display_name))
    else
      return ''
    end
  end
  def get_gname(options={})
    case
    when !options[:gid].nil?
      ux = System::Group.find(:first, :conditions=>"id=#{options[:gid]}")
      return '' if ux.nil?
      return Gis.trim(nz(ux.display_name))
    else
      return ''
    end
  end
  def get_group(options={})
    return !options[:gid].nil? ? System::Group.find(:first, :conditions=>"id=#{options[:gid]}") :
      !options[:uid].nil? ? System::User.find(:first, :conditions=>"id=#{options[:uid]}").groups[0] : nil
  end
end
