require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'
require 'byebug' 
require 'spec'

enable :sessions

include Model

before do
  if  (request.path_info != '/') && (session[:id] == nil)
    redirect('/error')
  end
 end
 

# Display Landing Page
#
# @see Model#get_all_cats
# @see Model#get_all_cats_liked
get('/') do
  user_id = session[:id].to_i
  @result = get_all_cats() 
  @result2 = get_all_cats_liked(user_id)
  slim(:"index")
end

# Page displayed if non-logged in user attempts to use functions for logged in users only
#
get('/notlogin') do
  slim(:"notlogin")
end

# Displays a login form
#
get('/showlogin') do
  slim(:login)
end

# Logs in user by updating sessions id if login-information matches database and redirects to Landing Page
#
# @param [String] username, The entered username
# @param [Password] password, The entered password
# 
# @see Model#get_user_info
post('/login') do
  username = params[:username]
  password = params[:password]
  result = get_user_info(username)
  pwdigest = result["pwdigest"]
  user_id = result["user_id"]
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = user_id 
    redirect('/')
  else 
    "FEL LÖSEN!"
  end
end

# Displays a register form
#
get('/register') do
  slim(:register)
end

# Registers new user if password & password_confirm match and redirects to Landing Page
#
# @param [String] username, The username to be registered
# @param [Password] password, The password
# @param [Password] password_confirm, Confirmation variable for password
#
# @see Model#create_user
begin post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
   
    password_digest = BCrypt::Password.create(password)
    create_user(username, password_digest)
    redirect('/')
  else
    "Lösenorden matchade inte!"
  end

end

# Displays all liked cats on one page
#
# @see Model#get_all_cats
# @see Model#get_all_cats_likes
get('/liked') do
  user_id = session[:id]
  @result = get_all_cats()
  @result2 = get_all_cats_liked(user_id)
  slim(:liked)
end

# Creates a new user-cat relation and redirects to previous page
#
# @param [Integer] cat_id, The ID of the cat
#
# @see Model#create_user_cat_relationship
post('/liked/new') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  create_user_cat_relationship(cat_id, user_id)
  redirect back
end

# Deletes an existing user-cat relation and redirects to previous page
#
# @param [Integer] cat_id, The ID of the cat
#
# @see Model#destroy_user_cat_relationship
post('/liked/delete') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  destroy_user_cat_relationship(cat_id, user_id)
  redirect back
end

# Displays user profile
#
# @see Model#get_user_info2
# @see Model#get_all_cats
# @see Model#get_all_cats_likes
get('/profile') do
  user_id = session[:id]
  if user_id != nil
    @result = get_user_info2(user_id)
    @result2 = get_all_cats()
    @result3 = get_all_cats_liked(user_id)
    slim(:profile)
  else
    slim(:error)
  end
end

# Displays page with form for user profile update
#
#@see Model#get_user_info2
get('/profile/edit') do
  user_id = session[:id]
    @result = get_user_info2(user_id)
  slim(:editprofile)
end

# Updates user profile and redirects to '/profile'
#
# @param [String] name, The full name of the user
# @param [String] email, The user's email adress
# @param [String] phone, The new content of the article
# 
# @see Model#get_user_info2
# @see Model#update_user
post('/profile/edit') do
  user_id = session[:id]
  name = params[:name]
  email = params[:email]
  phone = params[:phone]
  @result = get_user_info2(user_id)
  update_user(name, email, phone, user_id)
  redirect('/profile')
end

# Displays admin profile
#
# @see Model#get_user_info2
# @see Model#get_all_cats
get('/profile/admin') do
  user_id = session[:id]
  @result = get_user_info2(user_id)
  @result2 = get_all_cats()
  slim(:admin)
end

# Logs out user by reseting session id and redirects to Landing Page
#
post('/profile/users/logout') do
  session[:id] = nil 
  redirect('/')
end

# Displays page with form for cat creation
#
#@see Model#get_all_breeds
get('/cats/new') do
  @breeds = get_all_breeds()
  slim(:newcat)
end

# Creates a new cat and redirects to Landing Page
#
# @param [String] name, The name of the cat
# @param [Integer] breed_id, The cat's breed's id
# @param [String] gender, The gender of the cat
# @param [Integer] age, The age of the cat
# @param [Integer] size, The weight of the cat in Kilograms
#
# @see Model#create_cat
# @see Model#create_breed_relationship
post('/cats/new') do
  name = params[:name]
  breed_id = params[:breed_id]
  gender = params[:gender]
  age = params[:age]
  size = params[:size] 
  create_cat(name, breed_id, gender, age, size)
  create_breed_relationship(name, breed_id)
  redirect('/')
end

# Deletes an existing cat and redirects to previous page
#
# @param [Integer] cat_id, The ID of the cat
#
# @see Model#delete_cat
post('/cats/delete') do
  cat_id = params[:cat_id]
  delete_cat(cat_id)
  redirect back
end

# Displays a single cat
#
# @param [Integer] :cat_id, the ID of the cat
#
# @see Model#get_cat_info
# @see Model#get_all_cats_liked
# @see Model#get_breed
get('/cats/:cat_id/profile') do
  user_id = session[:id]
  cat_id = params[:cat_id].to_i
  result = get_cat_info(cat_id)
  @result2 = get_all_cats_liked(user_id)
  @result3 = get_breed(cat_id)
  slim(:catprofile, locals:{result:result})
end

end

