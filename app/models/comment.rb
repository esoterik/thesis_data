class Comment < ApplicationRecord
  belongs_to :author, optional: true
  belongs_to :conversation
end
