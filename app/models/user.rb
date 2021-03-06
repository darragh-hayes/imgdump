class User < ActiveRecord::Base
    attr_accessor :remember_token
    has_many :photos, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :favorites, dependent: :destroy
    has_many :favorite_photos, through: :favorites, source: :photo
    has_many :active_relationships, class_name:  "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :passive_relationships, class_name:  "Relationship", foreign_key: "followed_id", dependent:   :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower

    accepts_nested_attributes_for :photos
	
    before_save do |user| 
        user.email = email.downcase 
        end 
    validates :name, presence: true, length: { in: 1..50 }
    validates :password, length: { minimum: 6 }, allow_blank: true
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, 
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }
    has_secure_password      # A magic method!!

    # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  #favorite a photo
  def favorite(photo)
    favorites.create(photo_id: photo.id)
  end

  def favorited?(photo)
    favorite_photos.include?(photo)
  end

  #unfavorite  a photo
  def unfavorite(photo)
    favorites.find_by(photo_id: photo.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

end 