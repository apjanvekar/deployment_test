class Category < ActiveRecord::Base

#-------------validations-----------------------
validates_numericality_of :id , :message => "The ID must be a number!<br>"
validates_presence_of :name, :message => "Please specify a name!<br>"
validates_uniqueness_of :name, :message => "There is already a status with this name!<br>"
validates_length_of :name, :maximum => 100, :message => "The name cannot be bigger than 100 characters!<br>"
#-----------------------------------------------


 has_many :ticket
end
