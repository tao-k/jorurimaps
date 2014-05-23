# -*- encoding: utf-8 -*-
class Misc::Script::SocialUpdate

  def self.set_sequence_name
    items = System::SocialUpdate.find(:all)

    items.each do |item|
      tmp_seq = Util::Sequencer.next_id('social_updates_file', :md5 => true)
      item.tmp_id = tmp_seq.to_s
      date = item.published_at.strftime('%Y%m%d')
      seq  = Util::Sequencer.next_id('social_updates', :version => date)
      name = date + format('%04d', seq)
      item.name = Util::String::CheckDigit.check(name)
      item.save(:validate => false)
    end unless items.blank?
  end
end