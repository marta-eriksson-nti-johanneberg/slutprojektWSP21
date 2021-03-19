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
  @result = db.execute("SELECT * FROM cats") # WHERE user_id = ?",id
  @result2 = db.execute("SELECT * FROM user_cat_relationship WHERE user_id = ?", id)
  p @result2 
  slim(:"index")
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

post('/liked/new') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  db = SQLite3::Database.new('db/db.db')
  db.execute("INSERT INTO user_cat_relationship (user_id, cat_id) VALUES (?,?)", user_id, cat_id)
  redirect('/')
end

post('/liked/delete') do
  user_id = session[:id]
  cat_id = params[:cat_id]
  db = SQLite3::Database.new('db/db.db')
  db.execute("DELETE FROM user_cat_relationship WHERE cat_id = ? AND user_id = ?", cat_id, user_id)
  redirect('/')
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

