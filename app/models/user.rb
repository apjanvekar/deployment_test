class User < ActiveRecord::Base
require 'digest/sha2'
#Relationships
has_many :tickets

#before_save :populate_extra_hidden_field #run this method before a save is done



#-------------validations-----------------------
validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email!"  #make sure email format is correct
validates_uniqueness_of :email, :message => "This email address is already taken!<br>" #this will comb through the database and make sure email is unique
validates_presence_of :first_name, :last_name, :message => "This field is required!"
validates_confirmation_of :password, :message => "Password Confirmation Error!" #this will confirm the password, but you have to have an html input called password_confirmation
validates_length_of :email, :maximum => 255, :message => "Your Email address is too LONG!"
#-----------------------------------------------


#------------Login Authentication---------------
def self.authenticate(login, pass)
  u=find(:first, :conditions => ["email = ? and password_hash = ?", login, pass] )#check email column with the pass arg
  return nil if u.nil? 
  return u
end  
#----------------------------------------------- 

attr_accessor :password_confirmation, :password#these are the database columns, which are pulled from param

#--------Encrypt Password-------------------------
# make sure you're doing attr_accessor before this
def password=(pass)
  @password = pass = password_confirmation
  self.password_hash = Digest::SHA256.hexdigest(pass)
  #Salt!
  #self.salt = User.random_string(10) if !self.salt?
  #self.password_hash = User.encrypt(@password, self.salt)
end
#-------------------------------------------------


end
