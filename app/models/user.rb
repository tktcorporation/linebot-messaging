class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    lt4bytes: true
  validates :password,  presence: true, confirmation: :true, length: { in: 8..32 }, lt4bytes: true
  scope :undeleted, ->{ where(deleted: false) }
  has_many :bots, ->{ where(deleted: false) }
  require "digest/sha2"

  def self.find_with_email_and_pass(email, password)
    self.find_by(email: email, password: Manager.encrypt(password))
  end

  def self.create_with_email_and_pass(email, password)
    user = self.new(
      email: email,
      password: Manager.encrypt(password)
    )
    user.save!
  end

  def self.get_with_email(email)
    self.undeleted.find_by(email: email)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

end
