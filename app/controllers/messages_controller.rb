class MessagesController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
    @folder = params[:folder] == 'inbox' ? current_user.inbox :
      params[:folder] == 'outbox' ? current_user.outbox : current_user.inbox
    
    options = {
      :page => params[:page],
      :include => [:message => :author]
    }
    
    params[:order] || ""
    @order = {}
    case(params[:order])
      when "received_asc"
        options.merge!( :order => "message_copies.updated_at ASC" )
        @order.merge!( :received => "desc")
      when "received_desc"
        options.merge!( :order => "message_copies.updated_at DESC" )
        @order.merge!( :received => "asc")
      when "status_asc"
        options.merge!( :order => "message_copies.status ASC" )
        @order.merge!( :status => "desc")
      when "status_desc"
        options.merge!( :order => "message_copies.status DESC" )
        @order.merge!( :status => "asc")
      else
        options.merge!( :order => "message_copies.updated_at DESC" )
        @order.merge!( :received => "asc")
    end
    @messages = @folder.messages.paginate(options)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
      format.rss  { render :layout => false }
    end
  rescue StandardError => e
    logger.info( e.backtrace.join("\n") )
    flash[:error] = "Invalid messages folder!"
    redirect_to new_message_path
    #this needs to go to the main dashboard page, otherwise a recursive error occurs if folders are not yet setup
  end
  
  def show
    @thread = current_user.folders.find_message(params[:id]).message_thread(current_user)
    @root_id = @thread.first.root_id
    @parent_message_id = params[:id]
    @message = Message.new
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @thread }
      format.rss  { render :template => "messages/show.rss.builder", :layout => false }
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "No message thread found!"
    redirect_to messages_path
  end
  
  def new
    @message = Message.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message }
    end
  end
  
  def create
    @message = Message.new(params[:message])
    @message.author = current_user
    
    respond_to do |format|
      if @message.save
        flash[:notice] = 'message was successfully created.'
        format.html { redirect_to( messages_path+'?folder=outbox' ) }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  rescue StandardError => e
    logger.info( e.inspect )
    flash[:error] = "Error: Permission denied!"
    redirect_to messages_path
  end
  
  def reply
    @message = Message.new(params[:message])
    @message.author = current_user
    
    status = false
    if( !params[:parent_msg].blank? )
      begin
        parent_msg = current_user.folders.find_message(params[:parent_msg]).message
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = "No parent message thread found!"
        status = false
      else
        @message.root_id = parent_msg.root_id
        status = @message.save
        if( status )
          @message.move_to_child_of(parent_msg)
        end
      end
    end
    
    unless status
      @thread = current_user.folders.find_message(params[:parent_msg]).message_thread(current_user)
      @parent_message_id = params[:parent_msg]
      @root_id = @thread.first.root_id
    end
    
    respond_to do |format|
      if status
        flash[:notice] = 'message was successfully created.'
        format.html { redirect_to( :action => "show", :id => params[:parent_msg] ) }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
        # format.xhr { :json => @messge.to_json }
      else
        format.html { render :action => "show", :id => params[:parent_msg] }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
        # format.xhr { :json => @messge.to_json }
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "No message thread found!"
    redirect_to messages_path
  end
  
  def markread
    message = current_user.folders.find_message_for_update(params[:id])
    message.mark_as_read
    if message.save
      render :partial => "message", :locals => { :message => message }, :layout => false
    else
      render :text => "ERROR", :layout => false, :status => 500
    end
  rescue ActiveRecord::RecordNotFound => e
    render :text => "Error: No record found", :layout => false, :status => 500
  rescue AASM::InvalidTransition => e
    render :text => "Error: message was already marked as read.", :layout => false, :status => 500
  end
  
  def markunread
    message = current_user.folders.find_message_for_update(params[:id])
    message.mark_as_unread
    if message.save
      render :partial => "message", :locals => { :message => message }, :layout => false
    else
      render :text => "ERROR", :layout => false, :status => 500
    end
  rescue ActiveRecord::RecordNotFound => e
    render :text => "Error: No record found", :layout => false, :status => 500
  rescue AASM::InvalidTransition => e
    render :text => "Error: message was already marked as unread.", :layout => false, :status => 500
  end
  
end
