Factory.sequence :email do |i|
  "user_#{i}@msgbox.tld"
end

Factory.define :user do |u|
  u.email { Factory.next(:email) }
  u.password 'password'
  u.password_confirmation 'password'
end

Factory.define :message_user, :class => User do |u|
  u.email Faker::Internet.email
  u.real_name Faker::Name.name
  u.password 'somepasswd'
  u.password_confirmation 'somepasswd'
end
