# encoding: utf-8
module System::Model::Search

  def search_keyword(words, *columns)
    words.to_s.split(/[ 　]+/).each_with_index do |w, i|
      break if i >= 10
      self.and do |c|
        columns.each do |col|
          qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.or col, 'LIKE', "%#{qw}%"
        end
      end
    end
    self
  end

  def search_id(key_value, column)
    condition = Condition.new()
    condition.and do |cond|
      w1 = key_value.to_s
      cond.or column, '=', "#{w1.to_i}"
    end
    self.and condition
    return self
  end

  def search_ids(ids, *columns)
    condition = Condition.new()
    condition.and do |cond|
      columns.each do |column|
        ids.each do |key_value|
          w1 = key_value.to_s
          cond.or column, 'LIKE', "#{w1}"
        end
      end
    end
    self.and condition
    return self
  end

end