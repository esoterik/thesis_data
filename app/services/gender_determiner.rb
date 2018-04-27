require 'csv'

class GenderDeterminer
  def initialize(filename)
    @filename = filename
    @users = User.all
  end

  def run
    csv = CSV.read(filename, col_sep: '|', headers: true).to_a
    header = csv.shift
    gender_idx = header.index('Likely Gender')
    gender_scale_idx = header.index('Gender Scale')
    id_idx = header.index('ExternalId')
    csv.each do |row|
      user = User.find(row[id_idx])
      user.update!(gender_name: row[gender_idx].downcase,
                   gender_prob: row[gender_scale_idx])
    end
  end

  private

  attr_reader :users, :filename
end
