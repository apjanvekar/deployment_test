class CreateTickettexts < ActiveRecord::Migration
  def self.up

   create_table :tickettexts do |t|
      t.column :ticket_id, :integer
      t.column :post_type, :string
      t.column :user_id, :integer
      t.column :text_content, :text
      t.column :created_at, :datetime#this will get populated automatically
    end
   #Insert Test Example Ticket Text
   execute "INSERT INTO tickettexts VALUES (1, 1, 'user-post', 1, 'This is a post from a user.', '2007-09-15 12:00:00')"
   execute "INSERT INTO tickettexts VALUES (2, 1, 'tech-reply', 1, 'This is a post from a tech.', '2007-09-15 13:00:00')"
   execute "INSERT INTO tickettexts VALUES (3, 1, 'tech-comment', 1, 'This is a comment from a tech. The user will not see this.', '2007-09-19 14:00:00')"
   #example VALUES (id, ticket_id, post_type, user_id, text-content, created_at)
  end

  def self.down
    drop_table :tickettexts
  end
end
