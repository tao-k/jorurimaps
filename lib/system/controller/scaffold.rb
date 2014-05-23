# encoding: utf-8
module System::Controller::Scaffold
  def self.included(mod)
    mod.before_filter :initialize_scaffold
  end

  def initialize_scaffold

  end

  def edit
    show
  end
  
protected
  
  def _index(items)
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => items.to_xml }
    end
  end

  def _show(item)
    return send(params[:do], item) if params[:do]

    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => item.to_xml }
      format.json { render :text => item.to_json }
      format.yaml { render :text => item.to_yaml }
    end
  end

  def _create(item, options = {}, &block)
    respond_to do |format|
      if item.creatable? && item.save
        options[:after_process].call if options[:after_process]
        yield if block_given?

        location = options[:location] || options[:success_redirect_uri] ||
          (options[:success_action] ? url_for(:action => options[:success_action]) : url_for(:action => :index))
        flash[:notice] = options[:notice] || '登録処理が完了しました。'
        status = params[:_created_status] || :created
        format.html { redirect_to location }
        format.xml  { render :xml => item.to_xml, :status => status, :location => location }
      else
        flash.now[:notice] = '登録処理に失敗しました。'
        format.html { render :action => options[:error_action] || :new }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def _update(item, options = {}, &block)
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]
        yield if block_given?
        
        location = options[:location] || options[:success_redirect_uri] ||
          (options[:success_action] ? url_for(:action => options[:success_action]) : url_for(:action => :index))
        flash[:notice] = options[:notice] || '更新処理が完了しました。'
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash.now[:notice] = '更新処理に失敗しました。'
        format.html { render :action => options[:error_action] || :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def _update_items(items, options = {}, &block)
    respond_to do |format|
      if !items.map{|item| item.editable?}.include?(false) && save_items_within_transaction(items, options)
        options[:after_process].call if options[:after_process]
        yield if block_given?
        
        location = options[:location] || options[:success_redirect_uri] || 
          (options[:success_action] ? url_for(:action => options[:success_action]) : url_for(:action => :index))
        flash[:notice] = options[:notice] || '更新処理が完了しました。'
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash.now[:notice] = '更新処理に失敗しました。'
        format.html { render :action => options[:error_action] || :edit_items }
        format.xml  { render :xml => items.map{|item| item.errors}.to_xml, :status => :unprocessable_entity }
      end
    end
  end

  def send_recognition_mail(item)
    mail_fr = 'admin@192.168.0.2'
    subject = '【' + Core.title + '】 承認依頼'
    message = '下記URLから承認処理をお願いします。' + "\n\n" +
      url_for(:action => :show)

    item.recognizers.each do |_recognizer|
      mail_to = _recognizer.user.email
      mailer = Cms::Lib::Mail::Smtp.deliver_recognition(mail_fr, mail_to, subject, message)
    end
  end

  def _destroy(item, options = {}, &block)
    respond_to do |format|
      if item.deletable? && item.destroy
        options[:after_process].call if options[:after_process]
        yield if block_given?

        location = options[:location] || options[:success_redirect_uri] || 
          (options[:success_action] ? url_for(:action => options[:success_action]) : url_for(:action => :index))
        flash[:notice] = options[:notice] || '削除処理が完了しました。'
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash[:notice] = '削除処理に失敗しました。'
        format.html { render options[:error_action] || :action => :index }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def save_items_within_transaction(items, options = {})
    context = options[:context]
    ActiveRecord::Base.transaction do
      items.each{|item| item.save!(:context => context)}
    end
    return true
  rescue => e
    return false
  end
end