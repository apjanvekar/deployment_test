class Ticketlog < ActiveRecord::Base
  # Relationships
  belongs_to :user
  belongs_to :ticket
  
  # Validations
  validates_numericality_of :user_id, :message => "user_id must be a number!"
  validates_numericality_of :ticket_id, :message => "user_id must be a number!"

#before_save :test
#def test
# self.user_id = 0
#end


end
