require 'csv'

class CsvExporter
  CSV_DIR = 'csvs'

  def initialize(collection, attributes, filename)
    @collection = collection
    @attributes = attributes
    @filename = filename
  end

  def run
    CSV.open("#{CSV_DIR}/#{filename}", 'wb') do |csv|
      csv << attributes.map(&:to_s)
      collection.each do |item|
        row = []
        attributes.each { |a| row << item.send(a).to_s }
        row.compact!
        csv << row
      end
    end
  end

  private 

  attr_accessor :collection, :attributes, :filename
end
