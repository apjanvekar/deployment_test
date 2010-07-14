class Tickettext < ActiveRecord::Base
 #Relationships
 belongs_to :ticket
 belongs_to :user
end
