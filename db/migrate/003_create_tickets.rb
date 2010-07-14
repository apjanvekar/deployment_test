class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.column :subject, :string
      t.column :ticketstatus_id, :int
      t.column :category_id, :int
      t.column :user_id, :int
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
    end   
   #Insert Test Example Ticket
   execute "INSERT INTO `tickets` VALUES (1, 'This is an Example Ticket!', 1, 1, 1, '2007-09-15 12:00:00', '2007-09-15 12:00:00');"
  end

  def self.down
    drop_table :tickets
  end
end
