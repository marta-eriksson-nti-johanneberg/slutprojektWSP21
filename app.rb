require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'
require 'byebug'

enable :sessions

include Model

get('/') do
  user_id = session[:id].to_i
  @result = get_all_cats() 
  @result2 = get_all_cats_liked(user_id)
  slim(:"index")
end

get('/notlogin') do
  slim(:"notlogin")
end

get('/showlogin') do
  slim(:login)
end

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

get('/register') do
  slim(:register)
end

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

get('/liked') do
  user_id = session[:id]
  @result = get_all_cats()
  @result2 = get_all_cats_liked(user_id)
  slim(:liked)
end

post('/liked/new') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  create_user_cat_relationship(cat_id, user_id)
  redirect back
end

post('/liked/delete') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  destroy_user_cat_relationship(cat_id, user_id)
  redirect back
end

get('/profile') do
  user_id = session[:id]
  @result = get_user_info2(user_id)
  @result2 = get_all_cats()
  @result3 = get_all_cats_liked(user_id)
  slim(:profile)
end

get('/profile/edit') do
  user_id = session[:id]
    @result = get_user_info2(user_id)
  slim(:editprofile)
end

post('/profile/edit') do
  user_id = session[:id]
  name = params[:name]
  email = params[:email]
  phone = params[:phone]
  @result = get_user_info2(user_id)
  update_user(name, email, phone, user_id)
  redirect('/profile')
end

get('/profile/admin') do
  user_id = session[:id]
  @result = get_user_info2(user_id)
  @result2 = get_all_cats()
  slim(:admin)
end

post('/profile/users/logout') do
  session[:id] = nil 
  redirect('/')
end

get('/cats/new') do
  @breeds = get_all_breeds()
  slim(:newcat)
end

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

post('/cats/delete') do
  cat_id = params[:cat_id]
  delete_cat(cat_id)
  redirect back
end

get('/cats/:cat_id/profile') do
  user_id = session[:id]
  cat_id = params[:cat_id].to_i
  result = get_cat_info(cat_id)
  @result2 = get_all_cats_liked(user_id)
  @result3 = get_breed(cat_id)
  slim(:catprofile, locals:{result:result})
end

end

