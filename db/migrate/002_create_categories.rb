class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :name, :string
      t.column :parent, :string
      t.column :user_selectable, :integer, :default => 1
    end

    execute "insert into categories(name, parent, user_selectable) values('General', 0, 1)"
  end

  def self.down
    drop_table :categories
  end
end
