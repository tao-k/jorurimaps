# encoding: utf-8
module System::Model::UniqueId
  def self.included(mod)
    mod.before_create :set_unique_id
  end

  attr_accessor :unique_id_prefix

  def set_unique_id
    return if self.send(self.class.primary_key).present?
    
    unique_id = create_unique_id(self.class.primary_key)
    eval("self.#{self.class.primary_key} = unique_id")
    return true
  end

# @@phpの元関数
#function uniqe_id($key_id,$table_name,$default_value=""){
#	global $connect;
#	define("MAX_TRIAL",1000);
#
#	for($i=0; $i<MAX_TRIAL; $i++){
#		list($msec, $unixtime) = explode(" ", microtime());
#		$uniqe_id = $unixtime + $msec;
#		$uniqe_id = str_replace(".","",$uniqe_id);
#		if($default_value != ""){
#			$uniqe_id = $default_value."_".$uniqe_id;
#		}
#		$query = "select ".$key_id." from ".$table_name." where ".$key_id."='". $uniqe_id ."'";
#		$result = pg_query($connect, $query);
#		$num = pg_num_rows($result);
#
#		if($num == 0) return $uniqe_id;
#	}
#	return false;
#}
  def create_unique_id(column_name)
    (1..1000).each do |i|
#      unixtime = Time.now.to_f
#      list = unixtime.to_s.split(".")
#      unique_id = list[0].to_s + list[1].to_s
#      unique_id = format("%-20d", unique_id).gsub!(" ", "0")

      unique_id = get_unique_id

      item = self.class.new
      item.and :"#{column_name}", unique_id

      return unique_id unless item.find(:first)
    end
  end

  def get_unique_id
    unixtime = Time.now.to_f
    list = unixtime.to_s.split(".")
    unique_id = list[0].to_s + list[1].to_s
    unique_id = format("%-20d", unique_id).gsub!(" ", "0")

    if self.respond_to?(:unique_id_prefix) && !self.unique_id_prefix.blank?
      # prefix設定
      unique_id = "#{self.unique_id_prefix}_#{unique_id}"
    end

    return unique_id
  end

  module_function :get_unique_id
end
