# encoding: utf-8
module System::Controller::Admin::UserCsv
  def csvshow
    init_params
    return authentication_error(403) unless @u_role == true

    @item = System::UsersGroupsCsvdata.find(params[:id])
  end


  def csv
    init_params
    return authentication_error(403) unless @u_role == true

    cond  = "data_type = 'group' and level_no = 2"
    order = "code, sort_no, id"
    @csvdata = System::UsersGroupsCsvdata.find(:all, :order => order, :conditions => cond)
  end


  def csvup
    init_params
    return authentication_error(403) unless @u_role == true

    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'up'
      check = System::UsersGroupsCsvdata.csvup(params)
      if check[:result]
        flash[:notice] = '正常にインポートされました。'
        return redirect_to :action => :csvup
      else
        flash[:notice] = check[:error_msg]
        if check[:error_kind] == 'csv_error'
          file = System::Script::Tool.ary_to_csv(check[:csv_data])
          nkf_options = case par_item[:nkf]
          when 'utf8'
            '-w -W'
          when 'sjis'
            '-s -W'
          end
          filename = check[:error_csv_filename]
          filename = NKF::nkf('-s -W', filename) if @ie
          send_data(NKF::nkf(nkf_options, file), :type => 'text/csv', :filename => filename )
        else
          return redirect_to :action => :csvup
        end
      end
    else
    end
  end

  def csvget
    init_params
    return authentication_error(403) unless @u_role == true
    require 'csv'

    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'put'
      options = {}
      if par_item[:nkf] == 'sjis'
        options[:kcode] = 'sjis'
      end
      filename = "ユーザー・グループ情報_#{par_item[:nkf]}.csv"
      filename = NKF::nkf('-s -W', filename) if @ie

      csv_string = CSV.generate(:force_quotes => true) do |csv|
        System::UsersGroupsCsvdata.csvget.each do |x|
          csv << x
        end
      end

      csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
      csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
      send_data(csv_string, :type => 'text/csv', :filename => filename)
    else
    end
  end

  def csvset
    init_params
    return authentication_error(403) unless @u_role == true

    if params[:item].present? && params[:item][:csv] == 'set'
      _synchro

      if @errors.size > 0
        flash[:notice] = 'Error: <br />' + @errors.join('<br />')
      else
        flash[:notice] = '同期処理が完了しました'
      end
      redirect_to :action => :csvset
    else
      @count = System::UsersGroupsCsvdata.count
    end

  end



  def _synchro
    @errors  = []
    cond  = "data_type = 'group' and level_no = 2"
    order = "code, sort_no, id"
    @groups = System::UsersGroupsCsvdata.new.find(:all, :order => order, :conditions => cond)

    System::User.update_all("state = 'disabled'")
    System::UsersGroup.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null")
    #System::UsersGroupHistory.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null")

    System::Group.update_all("state = 'disabled'", "id != 1")
    System::Group.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "id != 1 and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)")

    #System::GroupHistory.update_all("state = 'disabled'", "id != 1")
    #System::GroupHistory.update_all("end_at = '#{Time.now.strftime("%Y-%m-%d 0:0:0")}'", "id != 1 and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)")

    group_sort_no = 0
    group_next_sort_no = Proc.new do
      group_sort_no = group_sort_no + 10
    end

    @groups.each do |d|

      cond = "parent_id = 1 and level_no = 2 and code = '#{d.code}' "
      order = "code"
      group = System::Group.find(:first, :conditions => cond, :order => order) || System::Group.new

      group.parent_id    = 1
      group.state        = d.state
      group.created_at ||= Core.now
      group.updated_at   = Core.now
      group.level_no     = 2
      group.version_id   = 0

      group.code         = d.code.to_s
      group.name         = d.name
      group.name_en      = d.name_en
      group.email        = d.email
      group.start_at     = d.start_at
      group.end_at       = d.end_at
      group.sort_no      = group_next_sort_no.call

      group.ldap_version = nil
      group.ldap         = d.ldap


      if group.id
        @errors << "group2-u : #{d.code}-#{d.name}" && next unless group.save
      else
        @errors << "group2-n : #{d.code}-#{d.name}" && next unless group.save
      end

      d.groups.each do |s|

        s_cond = "parent_id = #{group.id} and level_no = 3 and code = '#{s.code}'"
        s_order = "code"
        c_group = System::Group.find(:first, :conditions => s_cond, :order => s_order) || System::Group.new

        c_group.parent_id    = group.id
        c_group.state        = s.state
        c_group.updated_at   = Core.now
        c_group.level_no     = 3
        c_group.version_id   = 0

        c_group.code         = s.code.to_s
        c_group.name         = s.name
        c_group.name_en      = s.name_en
        c_group.email        = s.email
        c_group.start_at     = s.start_at
        c_group.end_at       = s.end_at
        c_group.sort_no      = group_next_sort_no.call

        c_group.ldap_version = nil
        c_group.ldap         = s.ldap

        if c_group.id
          @errors << "group3-u : #{s.code} - #{s.name}" && next unless c_group.save
        else
          @errors << "group3-n : #{s.code} - #{s.name}" && next unless c_group.save
        end

        user_sort_no = 0

        s.users.each do |u|
          user_sort_no = user_sort_no + 10

          cond = "code='#{u.code}'"
          user = System::User.find(:first, :conditions => cond) || System::User.new

          user.state              = u.state
          user.created_at       ||= Core.now
          user.updated_at         = Core.now

          user.code               = u.code
          user.ldap               = u.ldap
          user.ldap_version       = nil
          user.sort_no            = user_sort_no

          user.name               = u.name
          user.name_en            = u.name_en
          user.kana               = u.kana
          user.kana               = u.kana
          user.password           = u.password
          user.mobile_access      = u.mobile_access
          user.mobile_password    = u.mobile_password

          user.email              = u.email
          user.official_position  = u.official_position
          user.assigned_job       = u.assigned_job
          user.auth_no            = u.auth_no

          user.in_group_id        = c_group.id

          #そのユーザの現在の所属と違う部署に変更となった時
          user.user_groups.each do |ug|
            ug.update_attribute(:group_id, c_group.id) if ug.group_id != c_group.id
          end

          if user.id
            @errors << "user-u : #{u.code} - #{u.name}" && next unless user.save
          else
            @errors << "user-n : #{u.code} - #{u.name}" && next unless user.save
          end
          #save時にuser_groupsに更新がある場合があるので、読み直し
          user = System::User.find(:first, :conditions => cond)

          user_groups = user.user_groups # コールバックでsystem_users_groupsのデータは作成済み
          if user_groups.present?
            user_group = user_groups[0]
            if user_group.present?
              user_group.job_order = u.job_order
              user_group.start_at  = u.start_at
              user_group.end_at    = u.end_at
              user_group.save(:validate => false)
           end
          end
        end ##/users
      end ##/sections
    end ##/departments

    Rails.cache.clear
  end

end