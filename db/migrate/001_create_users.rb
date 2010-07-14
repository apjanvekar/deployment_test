class CreateUsers < ActiveRecord::Migration
  def self.up

    create_table :users do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :type_id, :integer
      t.column :password_hash, :string
      t.column :salt, :string
      t.column :phone_number, :string
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically  
      t.column :footer, :string
    end
   #-----Insert Data into table----------------
    execute "insert into users(first_name, last_name, email, type_id, password_hash, phone_number) values('John', 'Doe', 'user@test.com', 1, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', '5551119100')"
    execute "insert into users(first_name, last_name, email, type_id, password_hash, phone_number) values('Bob', 'Jones', 'tech@test.com', 2, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', '5551119100')"
    execute "insert into users(first_name, last_name, email, type_id, password_hash, phone_number) values('Admin', 'McNoogle', 'admin@test.com', 0, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', '0000000000')"
  end 

  def self.down
    drop_table :users
  end
end
