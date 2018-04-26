class ExcludeConversations
  def initialize(convos = Conversation.includes(:participants).all)
    @convos = convos
    @included_users = User.where(excluded: false).map(&:id)
  end

  def mark
    convos.each do |c|
      p = c.participants.map(&:id)
      excluded = (included_users - p) == included_users
      c.update(excluded: excluded)
    end
  end

  private 
  
  attr_reader :included_users, :convos
end
