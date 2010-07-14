class TechController < ApplicationController
 before_filter :authenticate_user , :except => [:index, :login, :create_new_user] #make sure the user is supposed to be here
 #I'm adding individual make_log's to whatever controller should have them instead.
 #after_filter :make_log, :only => [:create_ticket, :update_ticket_status, :update_account, :change_password, :save_post] #log the action

 def ajax_post_box
  render :layout => false
 end

 def test
 end

 def authenticate_user
  if session[:user].nil? #There's definitely no user logged in
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">You are not logged in or a tech!</font><br>"
   redirect_to :action => "index"
  else #there's a user logged in, but what type is he?
   @user = User.find(session[:user][:id]) # make sure user is in db, make sure they're not spoofing a session id
   if(@user.type_id == 2)
    # They are cool. Let them through.
   else
    flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You are not logged in as a Tech!</font>"
    redirect_to :action => "index"
   end
  end
 end

 def index
 end
 
 def collapse_ticket
  render :layout => false
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
       make_log(@ticket.id, "Created Ticket!")
       redirect_to :action => 'view_tickets'
      else #tickettext save failed
       flash[:message] = "There was an error when adding your post to the ticket!"
      end
     else  #save failed
      flash[:message] = "There was an error when entering your ticket into the database!<br>"
      @ticket.errors.each do |key, error|
       flash[:message] << error
      end
      redirect_to  :controller => 'tech', :action => 'open_ticket'
     end
    end
   end
 end
  
 def edit_account
   @user = User.find(session[:user][:id])
 end

 def edit_tickets
 end

 def expand_ticket
  render :layout => false
 end


 def login
    if request.post?
      if session[:user] = User.authenticate(params[:user][:email], Digest::SHA256.hexdigest(params[:user][:password]))
       flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Login Successful!</font><br>"
       #redirect_to_stored
       redirect_to :controller => 'tech', :action => "view_tickets"
      else # authentication failed!
        flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Login failed!</font><br>"
        redirect_to :controller => "tech", :action => "index"
      end
    end
 end

 def lookup_ticket
  @ticket = Ticket.find(params[:ticket][:id], :limit => 1) #look up the ticket to make sure it exists
  rescue ActiveRecord::RecordNotFound # If the ticket doesn't exist...
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;I couldn't find ticket: #{params[:ticket][:id]}</font><br>"
   redirect_to :action => "view_tickets"    
 end

 def make_log(ticketid = 0, msg = "") #log only certain actions(see above in before_filter to specify what actions to log)
  @log = Ticketlog.new(:log_type => "#{params[:action]}", :ticket_id => ticketid, :user_id => session[:user][:id], :log => "#{msg}")
  if @log.save
   #do nothing
  else
   flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Error saving log!</font>"
   logger.info "Failed creating log!"
  end
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
     if(params[:ticket][:ticketstatus_id].to_s != @ticket.ticketstatus_id.to_s)#if the ticket status has been changed
       @status = Ticketstatus.find(params[:ticket][:ticketstatus_id], :limit => 1)
       stat_change = " and status changed to: #{@status.name}"
       #Dave: for some reason, this controller is not detecting that the status hasn't changed.
       #flash[:message] << "params[:ticket][:ticketstatus_id] : #{params[:ticket][:ticketstatus_id]}<br>"
       #flash[:message] << " @ticket.ticketstatus_id : #{@ticket.ticketstatus_id}<br>"

  
       if(params[:ticket][:ticketstatus_id].to_s != @ticket.ticketstatus_id.to_s)
              flash[:message] << "The status is changed! #{@ticket.ticketstatus_id}  #{params[:ticket][:ticketstatus_id]}<br>"
       end

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
       make_log(@ticket_text.ticket_id, "Added post(#{params[:ticket][:post_type]})" + "#{stat_change}") # log it! 
     else
       flash[:message] <<  "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;There was a problem saving your post!</font><br>" 
     end
     #-------------------------------------------------- 

      #flash[:message] << "#{params.inspect} <br><br><br> #{@ticket.inspect} <br><br>@ticket.id: #{@ticket.id}<br>params[:ticket][:ticket_id]: #{params[:ticket][:ticket_id]}<br>params[:ticket][:status]: #{params[:ticket][:status]} "#for debugging
      redirect_to :controller => "tech", :action => "view_tickets"
    end 
  end
 end

 
 def update_ticket_status
   @ticket = Ticket.find(params[:ticket][:ticket_id])
   flash[:message] = ""
   if(@ticket.ticketstatus_id == params[:ticket][:ticketstatus_id])#they didn't actually select a new status
     flash[:message] << "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;You must choose a NEW ticket status!</font><br>"     
   else #they did select a new status, proceed normally	
    @status = Ticketstatus.find(params[:ticket][:ticketstatus_id], :limit => 1) #look up the new status for the log msg
    @stat_msg = "Changed ticket status to: #{@status.name}" # log message 
    if(@ticket.update_attribute(:ticketstatus_id, params[:ticket][:ticketstatus_id]))
      flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your ticket status has been changed successfully!</font><br>"
      make_log(params[:ticket][:ticket_id], @stat_msg) # Log it!
    end
    redirect_to :controller => "tech", :action => "view_tickets"
   end 
 end

 def view_logs
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
