class Ticket < ActiveRecord::Base
 validates_length_of :subject, :maximum => 50, :message => "Please specify a subject 50 characters or less."




 #Relationships
 belongs_to :user
 belongs_to :category
 belongs_to :ticketstatus
 has_many :tickettexts


 def text_content=(text) #this allows the form to CREATE a tick  to have a field that will populate a tickettext object.
 end
end
