class Comment < ApplicationRecord
  belongs_to :author, optional: true, class_name: 'User'
  belongs_to :conversation

  enum category: %i(normal review)
end
