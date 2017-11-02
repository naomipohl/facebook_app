class Status < ApplicationRecord
  validates :text, presence: true, length: { minimum: 5 }
  belongs_to :user
end
