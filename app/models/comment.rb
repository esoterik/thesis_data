class Comment < ApplicationRecord
  belongs_to :author, optional: true, class_name: 'User'
  belongs_to :conversation

  enum category: %i(normal review)
  
  def save_length
    update(length: body.length)
  end
end
