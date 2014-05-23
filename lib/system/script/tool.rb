# encoding: utf-8
class System::Script::Tool
  require 'csv'
  require 'pp'
  require 'yaml'


  def self.ar_to_csv(a_ar, _options={})
    options = HashWithIndifferentAccess.new(_options)
    return [] if a_ar.nil? || a_ar == []
    trans_hash_raw = Gis.load_yaml_files
    action = Gis.nz(options[:action], 'csvput')
    unless options['table_name'].nil?
      hash_name = options['table_name']
    else
      if a_ar.is_a?(ActiveRecord::Base)
        hash_name = a_ar.class.table_name
      elsif a_ar.is_a?(WillPaginate::Collection)
        hash_name = a_ar.last.class.table_name
      elsif a_ar.is_a?(Array)
        hash_name = a_ar.last.class.table_name if a_ar.last.is_a?(ActiveRecord::Base)
      end
    end
    trans_hash = self.get_trans_hash(trans_hash_raw, hash_name, action)
    cols = !options[:columns].nil? ? options[:columns] :
      !options[:cols].nil? ? options[:cols] :
      !trans_hash['_cols'].nil? ? trans_hash['_cols'].split(':') :
      a_ar.last.class.column_names.sort == a_ar.last.attribute_names.sort ? a_ar.last.class.column_names : a_ar.last.attribute_names
    cols = options[:cols].split(',') if cols.is_a?(String)
    opt_quotes = options[:quotes].nil? ? true : options[:quotes]
    opt_header = options[:header].nil? ? true : options[:header]

    col_types_all = a_ar.last.class.columns.collect{|x| [x.name, x.type]}
    col_types = cols.collect{|x| col_types_all.assoc(x)}
    idx = 0
    date_fld_idxs = []
    col_types.each_with_index do |col, idx|
      date_fld_idxs.push idx if col[1] == :datetime
    end
    ret = opt_header ? [cols] : []
    a_ar.each do |r|
      ret_1 = []
      cols.each_with_index do |col, idx|
        ret_1.push date_fld_idxs.index(idx).nil? ? r.send(col) : Gis.date_format('%Y/%m/%d %X', r.send(col))
      end
      ret.push ret_1
    end
    csv_string = CSV.generate(:force_quotes => opt_quotes) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
    csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
    return csv_string
  end

  def self.ary_to_csv(a_ary, _options={})
    options = HashWithIndifferentAccess.new(_options)
    return [] if a_ary.nil? || a_ary == []
    opt_quotes = options[:quotes].nil? ? true : options[:quotes]
    opt_header = options[:header].nil? ? nil : options[:header]

    ret = !opt_header.nil? ? [opt_header] : []
    a_ary.each do |r|
      ret.push r
    end
    csv_string = CSV.generate(:force_quotes => opt_quotes) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
    csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
    return csv_string
  end

end
