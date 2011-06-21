require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  
  before(:each) do
    @author = Factory.create(:user)
    @recipient_1 = Factory.create(:user)
    @recipient_2 = Factory.create(:user)
    
    @msg = Message.new(
      :subject => "first msg",
      :body => "hello world"
    )
    @msg.author = @author
    @msg.to_users = "#{@recipient_1.id},#{@recipient_2.id}"
  end
  
  it "should place a new message in outbox of sender and inbox of receiver" do
    @msg.should have(:no).errors_on(:attribute)
    @msg.save!
    @author.outbox.messages.count.should be(1)
    @recipient_1.inbox.messages.count.should be(1)
    @recipient_2.inbox.messages.count.should be(1)
  end

  it "should return the list of recipients for a message" do
    @msg.valid?.should be_true
    @msg.save!
    @msg.recipients.length.should be(2)
  end

  it "should store message thread" do
    @msg.save!
    
    msg2 = Message.new(
      :subject => "first msg",
      :body => "hello world too"
    )
    msg2.author = @recipient_1
    msg2.to_users = "#{@author.id}"
    msg2.root_id = @msg.root_id
    msg2.save!
    msg2.move_to_child_of(@msg)

    msg3 = Message.new(
      :subject => "first msg",
      :body => "hello world back again"
    )
    msg3.author = @author
    msg3.to_users = "#{@recipient_1.id}"
    msg3.root_id = msg2.root_id
    msg3.save!
    msg3.move_to_child_of(msg2)

    msg4 = Message.new(
      :subject => "second msg",
      :body => "hello world"
    )
    msg4.author = @author
    msg4.to_users = "#{@recipient_1.id}"
    msg4.save!
    
    msg5 = Message.new(
      :subject => "second msg",
      :body => "hello world bak"
    )
    msg5.author = @recipient_1
    msg5.to_users = "#{@author.id}"
    msg5.root_id = msg4.root_id
    msg5.save!
    msg5.move_to_child_of(msg4)
    
    @msg.reload
    @msg.ids_of_self_and_descendants_of_root.class.should be(Array)
    
    msg4.root.class.should be(Message)
  end
end
