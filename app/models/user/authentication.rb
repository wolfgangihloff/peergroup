class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :passcode

  # Automatically create the virtual attribute 'password_confirmation'.
  validates_confirmation_of :password

  # Password validations.
  validates_presence_of :password
  validates_length_of   :password, :within => 6..40

  before_save :encrypt_password

  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def remember_me!
    update_attribute(:remember_token, encrypt("#{salt}--#{id}--#{Time.now.utc}"))
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  private

  def encrypt_password
    unless password.nil?
      self.salt = make_salt
      self.encrypted_password = encrypt(password)
    end
  end

  def encrypt(string)
    secure_hash("#{salt}#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
end
