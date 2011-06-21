xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title       "Messages thread #{@root_id} for " + current_user.email.to_s
    xml.link        url_for :only_path => false, :controller => 'messages'
    xml.description "Message thread #{@root_id} for #" + current_user.email.to_s

    @thread.each do |message|
      xml.item do
        xml.title       message.subject
        xml.pubDate     message.created_at
        xml.author      message.author.email
        xml.link        url_for :only_path => false, :controller => 'messages', :action => 'show', :id => message.id
        xml.description message.body
        xml.guid        url_for :only_path => false, :controller => 'messages', :action => 'show', :id => message.id
      end
    end
  end
end
