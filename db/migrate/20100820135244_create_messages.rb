class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :author_id
      t.string :subject
      t.text :body
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :root_id
      t.string :cached_recipients_list
      t.timestamps
    end
  end
  
  def self.down
    drop_table :messages
  end
  
end
