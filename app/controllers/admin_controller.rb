class AdminController < ApplicationController
 before_filter :authenticate_user , :except => [:index, :login, :create_new_user] #make sure the user is supposed to be here



 def add_user
 end

 def ajax_post_boxc
  render :layout => false
 end

 def ajax_edit_user
  render :layout => false
 end

 def authenticate
  #don't delete this action
 end
  
 def authenticate_user
  if session[:user].nil? #There's definitely no user logged in
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">You are not logged in or an admin!</font><br>"
   redirect_to :action => "index"
  else #there's a user logged in, but what type is he?
   @user = User.find(session[:user][:id]) # make sure user is in db, make sure they're not spoofing a session id
   if(@user.type_id == 0)#make sure user is an admin(0=admin)
    #Do nothing, render controller
   else
    flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You are not logged in as a admin!</font>"
    redirect_to :action => "index"
   end
  end
 end

 def collapse_ticket
  render :layout => false
 end
 
 def create_new_category
  @category = Category.new(params[:category])
  @category.id = params[:category][:id] #set the id of the record manually

  flash[:message] = ""
  if @category.save
   flash[:message] <<  "<font color=green><image src=\"/images/icon_success.png\">&nbsp;The Category was successfully created!</font>"
  else  #save failed
   flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;There was a problem creating the category!</font><br>"
   @category.errors.each do |key,value|
    flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">Error: (#{key})....#{value}</font><br>"#print errors
   end
  end
  redirect_to :action => 'edit_ticket_categories'
 end

 def create_new_status
  @status = Ticketstatus.new(params[:status])
  @status.status_type = "general" # for now...
  @status.id = params[:status][:id] #set the id of the record manually

  flash[:message] = ""
  if @status.save
   flash[:message] <<  '<font color=green><image src=\"/images/icon_success.png\">&nbsp;The Status was successfully created!</font>'
  else  #save failed
   flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;There was a problem creating the status!</font><br>"
   @status.errors.each do |key,value|
    flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">Error: (#{key})....#{value}</font><br>"#print errors
   end
  end
  redirect_to :action => 'edit_ticket_statuses'
 end

 def create_new_user
  @user = User.new(params[:user])
  # render :text => @user.inspect
  flash[:message] = ""

  if params[:user][:password] != params[:user][:password_confirmation] #password doesn't match!
   flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Passwords do not match!</font><br>"  
  else
   if @user.save
    flash[:message] <<  '<font color=green><image src=\"/images/icon_success.png\">&nbsp;User was successfully created!</font>'
   else  #save failed
    flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;There was a problem creating your account! Below are details. </font><br>"
    @user.errors.each do |key,value|
     flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">Error: (#{key})....#{value}</font><br>"#print out any erro$
    end
   end
  end
  redirect_to :action => 'add_user'
 end

 def create_ticket
   if request.post?
    @user = User.find(session[:user][:id])
    if params[:ticket][:category] == "none"#category is blank
     flash[:message] = "Please Specify a category.<br>"
    else#everything's cool so far...
     #Create Ticket object and populate---------------------
     @ticket = Ticket.new(params[:ticket])
     @ticket.ticketstatus_id = 1
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
       @status.errors.each do |key,value|
        flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">Error: (#{key})....#{value}</font><br>"#print errors
       end
      end
     else  #save failed
      flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">There was an error when entering your ticket into the database!<br></font>"
      @ticket.errors.each do |key,value|
       flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">Error: (#{key})....#{value}</font><br>"#print errors
      end
      redirect_to :action => 'create_ticket'
     end
    end
   end
 end
  

 def edit_system_settings
  flash[:message] = "<i>This Feature is not yet implemented.</i>"
  redirect_to :action => "view_tickets"
 end

 def edit_ticket_categories
  @categories = Category.find(:all, :limit => 100)
 end

 def edit_ticket_categories_destroy
  @category = Category.find(params[:id], :limit => 1)
  #render :text => @category.inspect
  if @category.destroy
   flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Ticket Category Destroyed Successfully!</font><br>"
  else
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Failed Destroying Category!</font><br>" 
  end
  redirect_to :action => "edit_ticket_categories"
 end

 def edit_ticket_statuses
  @statuses = Ticketstatus.find(:all, :limit => 100)
 end

 def edit_ticket_statuses_destroy
  # make sure the admin can't delete status 1(new)
  if (params[:id] == "1" || params[:id] ==  "2")
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Sorry, You can't delete the 'new' or 'resolved' status. They're important to have!</font><br>" 
  else # The status to be deleted isn't 'new'
   @status = Ticketstatus.find(params[:id], :limit => 1)
   #render :text => @status.inspect
   if @status.destroy
    flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Ticket Status Destroyed Successfully!</font><br>"
   else
    flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Failed Destroying Status!</font><br>" 
   end
  end
  redirect_to :action => "edit_ticket_statuses"
 end

 def edit_users
   @increment = 100 # show x tickets per page

   if params[:offset].nil? # no offset is defined
    @offset = 0 # @offset = where to start looking for tickets
   else 
    @offset = params[:offset].to_i
   end

   @tick_limit = @offset.to_i + @increment.to_i #The max amount of ticks to display

  #Dave: I'll come back and add some pagintation here.

  @users = User.find(:all,:offset => @offset, :limit => @increment )

 end

 def edit_users_destroy
  @user = User.find(params[:id], :limit => 1)
  if @user.id == session[:user][:id]
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You can't delete the user you're logged in as!</font><br>"
  else
   if @user.destroy
    flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;User Destroyed Successfully!</font><br>"
   else
    flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Failed Destroying User!</font><br>"
   end
  end
  redirect_to :action => "edit_users"

 end

 def edit_user_update
  #render :text => params.inspect	
  @user = User.find(params[:user_id])
  flash[:message] = "" 
  if @user.update_attributes(params[:user])
   flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;#{@user.email} saved successfully!!</font><br>"
  else
   flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Failed Saving!</font><br>" 
  end
  #redirect_to :login
 end

 def expand_ticket
  render :layout => false
 end

 def index
  render :layout => false
 end
 
 def login
    if request.post?
      if session[:user] = User.authenticate(params[:user][:email], Digest::SHA256.hexdigest(params[:user][:password]))
       flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Login Successful!</font><br>"
       #redirect_to_stored
       session[:logged_in] = "y"
       @msg = "#{params[:user][:email]} logged in successfully!<br>" 
       redirect_to :action => "view_tickets"
      else #login failed
        flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Login Failed!</font><br>"
        redirect_to :controller => "admin" , :action => "index"
      end
    end
 end

 def lookup_ticket
  #render :text => params.inspect
  @ticket = Ticket.find(params[:ticket][:id], :limit => 1) #look up the ticket to make sure it exists
  rescue ActiveRecord::RecordNotFound # If the ticket doesn't exist...
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;I couldn't find ticket: #{params[:ticket][:id]}</font><br>"
   redirect_to :action => "view_tickets"    
 end

 def open_ticket
   @user = User.find(session[:user][:id])
   @categories = Category.find(:all, :limit => 100)
   @statuses = Ticketstatus.find(:all)
 end

 def save_post
  if request.post?
    flash[:message] = ""
    #----------Check and Updated Status-----------------
    if(params[:ticket][:status] == "none")#make sure they set a status
     flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Please choose a status other than #{params[:ticket][:status]}!</font><br>" 
    else
     @ticket = Ticket.find(params[:ticket][:ticket_id])#test to see if the status has changed
     if(params[:ticket][:ticketstatus_id] != @ticket.ticketstatus_id)#if the ticket status has been changed
      if @ticket.update_attribute(:ticketstatus_id, params[:ticket][:ticketstatus_id])#save the status
       flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;The status of your ticket was changed successfully!</font><br>"
      else
       flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;There was a problem changing your ticket status! #{params[:ticket][:status]}!</font><br>" 
      end
     else #the ticket status is the same
       flash[:message] << "<font color=green><image src=\"/images/icon_warning.png\">&nbsp;Your Ticket Status will stay the same.</font><br>" 
     end
     #--------------------------------------------------  

     #----------Add Post to Ticket----------------------
     #add the ticket text to the tick
     @ticket_text = Tickettext.new()
     @ticket_text.text_content = params[:ticket][:text_content]
     @ticket_text.user_id = session[:user][:id]
     @ticket_text.ticket_id = params[:ticket][:ticket_id]
     @ticket_text.post_type = params[:ticket][:post_type]
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
 end
 
 def update_ticket_status
   @ticket = Ticket.find(params[:ticket][:ticket_id])
   flash[:message] = ""
   if(@ticket.ticketstatus_id == params[:ticket][:ticketstatus_id])#they didn't actually select a new status
     flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You must choose a NEW ticket status!</font><br>"     
   else #they did select a new status, proceed normally	
    if(@ticket.update_attribute(:ticketstatus_id, params[:ticket][:ticketstatus_id]))
      flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your ticket status has been changed successfully!</font><br>"
    end
    redirect_to :controller => "admin", :action => "view_tickets"
   end 
 end

 def view_logs
  @users = User.find(:all, :conditions => ["type_id = ?", "2"], :limit => 100 )  # find all tech logs
 end

 def view_logs_for_user
  @user = User.find(params[:id], :limit => 1) 
 end

 def view_tickets   
   @categories = Category.find(:all, :limit => 100) # for use in select in view
   @statuses = Ticketstatus.find(:all, :limit => 100) # for use in select in view

   @increment = 100 # show x tickets per page

   if params[:offset].nil? # no offset is defined
    @offset = 0 # where to start looking for tickets
   else
    @offset = params[:offset].to_i
   end
   
   @tick_limit = @offset.to_i + @increment.to_i #The max amount of ticks to display

   if(params[:category_id] && params[:category_id] != "none")# if a category is selected
    @category = Category.find(params[:category_id], :limit => 1)
    @category_name = @category.name    
    if(params[:status_id] &&  params[:status_id] != "none") # if a status is selected too
     @status = Ticketstatus.find(params[:status_id], :limit => 1)
     @status_name = @status.name
     @tickets = Ticket.find(:all, :conditions => ["category_id = ? and ticketstatus_id = ?", params[:category_id], params[:status_id]  ], :offset => @offset, :limit => @increment  )    
    else #no status
     @status_name = "All"
     @tickets = Ticket.find(:all, :conditions => ["category_id = ? and ticketstatus_id != 2", params[:category_id] ], :offset => @offset, :limit => @increment )
    end

   else # no category was selected
    @category_name = "All"
    if(params[:status_id] && params[:status_id] != "none") # if a status is selected too
     @status = Ticketstatus.find(params[:status_id], :limit => 1)
     @status_name = @status.name
     @tickets = Ticket.find(:all, :conditions => ["ticketstatus_id = ?", params[:status_id]  ], :offset => @offset, :limit => @increment  )    
    else # no status is selected
     @status_name = "All"
     @tickets = Ticket.find(:all, :conditions => ["ticketstatus_id != 2"], :offset => @offset, :limit => @increment )
    end 
   end

 end 



end

