db = SQLite3::Database.new('db/db.db')
db.results_as_hash = true

def get_all_cats()
    result = db.execute("SELECT * FROM cats") 
    return result
end

def get_all_cats_liked(user_id)
    result = db.execute("SELECT * FROM user_cat_relationship WHERE user_id = ?", user_id)
    return result
end

def get_user_info(username)
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    return result
end

def create_user(username,password_digest)
    result = db.execute("INSERT INTO users (username,user_role,pwdigest) VALUES (?,?,?)",username,"user",password_digest)
    return result
end

def create_user_cat_relationship(cat_id,user_id)
    result = db.execute("INSERT INTO user_cat_relationship (user_id, cat_id) VALUES (?,?)", user_id, cat_id)
    return result
end






