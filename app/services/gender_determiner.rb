require 'csv'

class GenderDeterminer
  def initialize(filename)
    @filename = filename
    @users = User.all
  end

  def run
    csv = CSV.read(filename, col_sep: '|', headers: true).to_a
    header = csv.shift
    first_name_idx = header.index('First Name')
    gender_idx = header.index('Likely Gender')
    gender_scale_idx = header.index('Gender Scale')
    binding.pry
    #comment
  end

  private

  attr_reader :users, :filename
end
