require 'spec_helper'

describe "messages/new.html.erb" do
=begin
  before(:each) do
    assign(:message, stub_model(Message,
      :new_record? => true
    ))
  end

  it "renders new message form" do
    render

    rendered.should have_selector("form", :action => messages_path, :method => "post") do |form|
    end
  end
=end
end
