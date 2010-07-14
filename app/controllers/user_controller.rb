class UserController < ApplicationController
 before_filter :authenticate_user , :except => [:index, :login, :create_new_user] #make sure the user is a regular user
 #after_filter :make_log, :except => [:index, :login, :logout, :view_tickets] #log the action

 def ajax_post_box
  render :layout => false
 end
 
 def test(controller)
  render :text => "#{controller}"
 end

 def make_log
  @log = Ticketlog.new(:log_type => "#{params[:action]}", :ticket_id => "1", :user_id =>  session[:user][:id], :log => "#{params[:action]}")
  if @log.save
   #render :text => "Log saved!"
  else
   #render :text => "Log failed!"
  end
 end
  
 #def authenticate
  #don't delete this action
 #end
 
 def authenticate_user
  if session[:user].nil? # There's definitely no user logged in
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">You are not logged in!</font><br>"
   redirect_to :action => "index"
  else #there's a user logged in, but what type is he?
   @user = User.find(session[:user][:id]) # make sure user is in db, make sure they're not spoofing a session id
   if @user.type_id == 1 # make sure they're a user
    #Proceed, render controller
   else #they're not a user... kick em out!
    flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You are not logged in as a user!</font>"
    redirect_to :action => "index"
   end
  end
 end

 def index
 end
 
 def collapse_ticket
  render :layout => false
 end

 def create_new_user
  if request.post?
   @msg = Array.new
   if(params[:user][:password] != params[:user][:password_confirmation])
    @msg << "<font color=red>Your Passwords Do NOT match!</font>" 
   else
    @user = User.new(params[:user])
    @user.type_id = 1
    if @user.save
     @msg  << 'User was successfully created!'
     #redirect_to :action => 'index'
    else  #save failed
     @msg << "<font color=red>There was a problem creating your account!<br>Details:<br>"
     @user.errors.each do |key,value|
      @msg << "<font color=red><image src=\"/images/icon_failure.png\">Error: (#{key})....#{value}</font><br>"#print out any errors!
     end
     @msg << "</font><br><a href=\"./\" class=\"right_link\"><< Back</a>"
    end
   end
  end
 end
 
 def create_ticket
   if request.post?
    @user = User.find(:first, :conditions => {:id => session[:user][:id] }) 
    if params[:ticket][:category] == "none"#category is blank
     flash[:message] = "Please Specify a category.<br>"
    else#everything's cool so far...
     #Create Ticket object and populate---------------------
     @ticket = Ticket.new(params[:ticket])
     @ticket.ticketstatus_id = 1 #Create it as status type=1(new)
     @ticket.user_id = session[:user][:id]
     if @ticket.save#save ticket & text in db.
      flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your ticket was successfully created!</font><br>"
      #Create Tickettext object and populate-----------------
      @ticket_text = Tickettext.new()
      @ticket_text.text_content = params[:ticket][:text_content]     
      @ticket_text.user_id = session[:user][:id]    
      @ticket_text.post_type = "user-post"
      @ticket_text.ticket_id = @ticket.id
      if @ticket_text.save#Add the text to the ticket
       flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your post was added to the ticket successfully!</font><br>"
       flash[:message] << "<font color=green><image src=\"/images/icon_info.png\">&nbsp;<b>Your new ticket number is: #{@ticket.id}</font>"
       redirect_to :action => 'view_tickets'
      else #tickettext save failed
       flash[:message] = "There was an error when adding your post to the ticket!"
      end
     else  #save failed
      flash[:message] = "There was an error when entering your ticket into the database!"
      redirect_to :action => 'create_ticket'
     end
    end
   end
 end
  
 def edit_account
   @user = User.find(:first, :conditions => {:id => session[:user][:id] })
 end

 def expand_ticket
  render :layout => false
 end

 def login
    if request.post?
      if session[:user] = User.authenticate(params[:user][:email], Digest::SHA256.hexdigest(params[:user][:password]))
       if(session[:user][:type_id] != 1)#that user is not a normal customer! they might be trying to log in as a tech, etc..
	reset_session
        flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You're Logged into the wrong area!</font><br>"
        redirect_to :action => "index"
       else#they are in the right place
        flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Login Successful!</font><br>"
        #redirect_to_stored
        session[:logged_in] = "y"
         @msg = "<font color=green><image src=\"/images/icon_success.png\">#{params[:user][:email]} logged in successfully!</font><br>" 
	redirect_to :action => "view_tickets"
       end
      else
        flash[:message] = "Login unsuccessful"
        @msg = "Login Failed!<br>"
      end
    end
 end


 def open_ticket
   @user = User.find(:first, :conditions => {:id => session[:user][:id] }, :limit => 1)
   @categories = Category.find(:all,:limit => 100)
   #@statuses = Ticketstatus.find(:all)#not implemented yet
 end

 def save_post
  if request.post?
    flash[:message] = ""

     #----------Add Post to Ticket----------------------
     #add the ticket text to the tick
     @ticket_text = Tickettext.new()
     @ticket_text.text_content = params[:ticket][:text_content]
     @ticket_text.user_id = session[:user][:id]
     @ticket_text.ticket_id = params[:ticket][:ticket_id]
     @ticket_text.post_type = "user-post"
     if @ticket_text.save#save the text
       flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your post was added successfully!</font><br>"
     else
       flash[:message] <<  "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;There was a problem saving your post!</font><br>" 
     end
     #-------------------------------------------------- 

      #flash[:message] << "#{params.inspect} <br><br><br> #{@ticket.inspect} <br><br>@ticket.id: #{@ticket.id}<br>params[:ticket][:ticket_id]: #{params[:ticket][:ticket_id]}<br>params[:ticket][:status]: #{params[:ticket][:status]} "#for debugging
      redirect_to :action => "view_tickets"
  end
 end
 
 def update_ticket_status
   @ticket = Ticket.find(params[:ticket][:ticket_id], :limit => 1)
   flash[:message] = ""
   if(@ticket.ticketstatus_id == params[:ticket][:ticketstatus_id])#they didn't actually select a new status
     flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You must choose a NEW ticket status!</font><br>"     
   else #they did select a new status, proceed normally	
    if(@ticket.update_attribute(:ticketstatus_id, params[:ticket][:ticketstatus_id]))
      flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your ticket status has been changed successfully!</font><br>"
    end
    redirect_to :action => "view_tickets"
   end 
 end

 def view_tickets
   @user = User.find(:first, :conditions => {:id => session[:user][:id] } )
   @categories = Category.find(:all)
   @tickets = Ticket.find(:all, :conditions => { :user_id => session[:user][:id] }, :limit => "100")
 end 

end

