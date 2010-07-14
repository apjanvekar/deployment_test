class CreateTicketstatuses < ActiveRecord::Migration
  def self.up
    create_table :ticketstatuses do |t|
	t.column :name, :string
        t.column :status_type, :string
	t.column :user_selectable, :int
    end
   execute "INSERT INTO `ticketstatuses` VALUES (1, 'New', 'general', 0 )"
   execute "INSERT INTO `ticketstatuses` VALUES (2, 'Resolved', 'general', 1)"
   execute "INSERT INTO `ticketstatuses` VALUES (3, 'Priority-Low', 'general', 1)"
   execute "INSERT INTO `ticketstatuses` VALUES (4, 'Priority-Medium', 'general', 1)"
   execute "INSERT INTO `ticketstatuses` VALUES (5, 'Priority-High', 'general', 1)"
 #  SystemSetting.create :name => "Resolved", :status_type => "Closed", :selectable => 1


  end

  def self.down
    drop_table :ticketstatuses
  end
end

