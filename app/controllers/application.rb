class ApplicationController < ActionController::Base
# *Security Reminder: All actions listed here are still subject to authentication in the various controllers,
#                     so the user still has to be logged in to perform the particular action. These actions
#                     below should be secure.

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_mystic_session_id'

 #Global User Methods
 def change_password
  if request.post?
   @user = session[:user]
   if params[:user][:password].blank?#password is empty
    flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Password cannot be blank!</font><br>"
    redirect_to :controller => params[:controller], :action => 'edit_account'
   else #password is filled
    if params[:user][:password] != params[:user][:password_confirmation] #password doesn't match!
     flash[:message] = "<font color=red><image src=\"/images/icon_failure.png\">&nbsp;Passwords do not match!</font><br>"
     redirect_to :controller => params[:controller], :action => 'edit_account'
    else#passwords match
     @user.update_attributes(:password => params[:user][:password], :password_confirmation =>params[:user][:password_confirmation])
     if @user.save
      flash[:message] = "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Password changed successfully</font><br>"
      redirect_to :controller => params[:controller], :action => 'edit_account'
     end
    end
   end
  end
 end

 def logout
  session[:user] = nil
  reset_session
  flash[:message] = "<font color=green><image src=\"/images/icon_info.png\">&nbsp;You have been logged out! Have a nice day.</font><br>"
  redirect_to :controller => params[:controller], :action => "index" #redirect them to the controller they came from
 end

 def update_account
  if request.post?
    @user = User.find(session[:user][:id])
     flash[:message] = ""
   if(@user.update_attribute(:first_name, params[:user][:first_name]))
    flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your first name was updated successfully!</font><br>"
   end
   if(@user.update_attribute(:last_name, params[:user][:last_name]))
     flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your last name was updated successfully!</font><br>"
   end
   if(@user.update_attribute(:phone_number, params[:user][:phone_number]))
     flash[:message] << "<font color=green><image src=\"/images/icon_success.png\">&nbsp;Your phone number was updated successfully!</font><br>"
   end
   redirect_to :controller => params[:controller], :action => "edit_account"
  end
 end


end
