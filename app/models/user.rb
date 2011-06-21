class User < ActiveRecord::Base
  
  has_many :folders, :extend => UserFolderExtension
  after_create {
    |record|
    # Create the default folders for this record
    record.folders << Folder.new( :name => "Inbox" )
    record.folders << Folder.new( :name => "Outbox" )
  }
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  def inbox
    folders.find_by_name("Inbox")
  end
  
  def outbox
    folders.find_by_name("Outbox")
  end
  
end
