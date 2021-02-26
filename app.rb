require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE user_id = ?",id) 
  slim(:"todos/index",locals:{todos:result})
end

get('/showlogin') do
  slim(:login)
end


post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
   
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
    redirect('/')
  else
    "Lösenorden matchade inte!"
  end

end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?", username).first
  pwdigest = result["pwdigest"]
  id = result["id"]
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id 
    redirect('/todos')
  else 
    "FEL LÖSEN!"
  end
end


get('/register') do
  slim(:register)
end

post('/todos/delete') do
  id = params[:number]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.execute("DELETE FROM todos WHERE id = ?", id)
  redirect('/todos')
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

