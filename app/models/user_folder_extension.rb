module UserFolderExtension

  def find_message(id)
    msg = MessageCopy.find_by_id(
      id,
      :joins => [ :folder => :user ],
      :conditions => ["users.id = ?", @owner.id]
    )
    raise ActiveRecord::RecordNotFound if msg.nil?
    return msg
  end
  
  def find_message_for_update(id)
    msg = MessageCopy.find_by_id(
      id,
      :include => [ :folder => :user ],
      :conditions => ["users.id = ?", @owner.id]
    )
    raise ActiveRecord::RecordNotFound if msg.nil?
    return msg
  end

end
