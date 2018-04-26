
class UserDataUpdater
  def initialize(users = User.all)
    @users = users
  end

  def run
    users.each do |user|
      begin
        data = UserQuery.new(user).run
        data[:first_name] = data[:name].split(' ').first if data[:name]
        user.update!(**data)
      rescue ActiveRecord::RecordInvalid => e
        binding.pry
        puts "Failed to update user #{user.username}"
      end
    end
  end

  private

  attr_reader :users
end
