class User < ApplicationRecord
    validates_presence_of :login
    validates_presence_of :password
    validates_presence_of :email
    validates :login, uniqueness: { case_sensitive: false }
    validates :email, uniqueness: { case_sensitive: false }

end
