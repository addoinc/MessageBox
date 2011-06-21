class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :messages, :class_name => "MessageCopy"
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
  attr_accessible :name
end
