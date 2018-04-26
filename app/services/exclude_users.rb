class ExcludeUsers
  def initialize(users = User.includes(contributions: :repo).all)
    @users = users
  end

  def mark
    users.each do |u|
      excluded = u.contributions.first.excluded? || u.contributions.count > 1
      u.update(excluded: excluded)
    end
  end

  private 
  
  attr_reader :users
end
