class User
  include NoBrainer::Document

  field :username, type: String, index: true
  field :encrypted_password, type: String

  def self.oauth_authenticate(_client, username, password)
    user = where(username: username.to_s).first
    user if user && user.encrypted_password == password
  end
end
