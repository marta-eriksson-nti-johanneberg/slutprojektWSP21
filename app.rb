require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'
require 'byebug'

enable :sessions

get('/') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  @result = db.execute("SELECT * FROM cats") 
  @result2 = db.execute("SELECT * FROM user_cat_relationship WHERE user_id = ?", id)
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
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?", username).first
  pwdigest = result["pwdigest"]
  id = result["user_id"]
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id 
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
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO users (username,user_role,pwdigest) VALUES (?,?,?)",username,"user",password_digest)
    redirect('/')
  else
    "Lösenorden matchade inte!"
  end

end

get('/liked') do
  user_id = session[:id]
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  @result = db.execute("SELECT * FROM cats")
  @result2 = db.execute("SELECT * FROM user_cat_relationship WHERE user_id = ?", user_id)
  slim(:liked)
end

post('/liked/new') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  db = SQLite3::Database.new('db/db.db')
  db.execute("INSERT INTO user_cat_relationship (user_id, cat_id) VALUES (?,?)", user_id, cat_id)
  redirect back
end

post('/liked/delete') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  db = SQLite3::Database.new('db/db.db')
  db.execute("DELETE FROM user_cat_relationship WHERE cat_id = ? AND user_id = ?", cat_id, user_id)
  redirect back
end

get('/profile') do
  user_id = session[:id]
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  @result = db.execute("SELECT * FROM users WHERE user_id = ?", user_id).first
  @result2 = db.execute("SELECT * FROM cats")
  @result3 = db.execute("SELECT * FROM user_cat_relationship WHERE user_id = ?", user_id)
  slim(:profile)
end

get('/profile/edit') do
  user_id = session[:id]
  slim(:editprofile)
end

get('/profile/admin') do
  user_id = session[:id]
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  @result = db.execute("SELECT * FROM users WHERE user_id = ?", user_id).first
  @result2 = db.execute("SELECT * FROM cats")
  slim(:admin)
end

post('/profile/users/logout') do
  session[:id] = nil 
  redirect('/')
end

get('/cats/new') do
  slim(:newcat)
end

post('/cats/new') do
  name = params[:name]
  gender = params[:gender]
  age = params[:age]
  size = params[:size] 
  db = SQLite3::Database.new('db/db.db')
  db.execute("INSERT INTO cats (name, gender, age, size) VALUES (?,?,?,?)", name, gender, age, size)
end
post('/cats/delete') do
  cat_id = params[:cat_id]
  db = SQLite3::Database.new('db/db.db')
  db.execute("DELETE FROM cats WHERE cat_id = ?", cat_id)
  redirect back
end

get('/cats/:cat_id/profile') do
  cat_id = params[:cat_id]
  db = SQLite3::Database.new('db/db.db')
  @result = db.execute("SELECT * FROM cats WHERE cat_id = ?", cat_id)
  slim(:catprofile)
end

post('/todos/delete') do
  id = params[:number]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.execute("DELETE FROM todos WHERE id = ?", id)
  redirect('/')
end

post('/todos/new') do
  content = params[:content]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  db.execute("INSERT INTO todos (content, user_id) VALUES (?,?)",content,userid)
  redirect('/todos')
end

post('/todos/edit') do
  content = params[:content]
  id = params[:number]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  db.execute("UPDATE todos SET content = ? WHERE id = ?",content,id)
  redirect('/todos')
end 
end

