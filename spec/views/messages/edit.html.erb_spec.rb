require 'spec_helper'

describe "messages/edit.html.erb" do
=begin
  before(:each) do
    @message = assign(:message, stub_model(Message,
      :new_record? => false
    ))
  end

  it "renders the edit message form" do
    render

    rendered.should have_selector("form", :action => message_path(@message), :method => "post") do |form|
    end
  end
=end
end
