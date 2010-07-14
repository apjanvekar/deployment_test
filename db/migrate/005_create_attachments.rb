class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments  do |t|
      t.column :ticket_text_id, :integer
      t.column :mime_type, :string
      t.column :data, :binary
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :attachments
  end
end
