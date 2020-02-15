class User < ApplicationRecord
    require 'digest/md5'

    validates_presence_of :login
    validates_presence_of :password
    validates_presence_of :email
    validates :login, uniqueness: { case_sensitive: false }
    validates :email, uniqueness: { case_sensitive: false }
    before_save :encrypt

    def encrypt
        self.password = Digest::MD5.hexdigest(password)
    end
end
