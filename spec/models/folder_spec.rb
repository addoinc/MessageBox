require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Folder do
  before(:each) do
    @author = Factory.create(:user)
    @recipient_1 = Factory.create(:user, :email => Factory.next(:email))
    @recipient_2 = Factory.create(:user, :email => Factory.next(:email))
    
    @msg = Message.new(
      :subject => "first msg",
      :body => "hello world"
    )
    @msg.author = @author
    @msg.to_users = "#{@recipient_1.id}"
  end
  
  it "should raise ActiveRecord::RecordNotFound when trying to access other user's message" do
    @msg.should have(:no).errors_on(:attribute)
    @msg.save!
    lambda { 
      @recipient_2.folders.find_message(@recipient_1.inbox.messages.first.id)
    }.should raise_error(ActiveRecord::RecordNotFound)
    msg = @recipient_1.folders.find_message(@recipient_1.inbox.messages.first.id )
    msg.subject.should == "first msg"
    msg.body.should == "hello world"
  end
  
end
