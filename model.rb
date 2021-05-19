require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

enable :sessions

module Model

    def get_db()    
        db = SQLite3::Database.new('db/db.db')
        db.results_as_hash = true
        return db
    end

    def get_all_cats()
        db = get_db()
        result = db.execute("SELECT * FROM cats")
        return result
    end

    def get_all_cats_liked(user_id)
        db = get_db()
        result = db.execute("SELECT * FROM user_cat_relationship WHERE user_id = ?", user_id)  
        return result
    end

    def get_user_info(username)
        db = get_db()
        result = db.execute("SELECT * FROM users WHERE username = ?", username).first
        return result
    end

    def get_user_info2(user_id)
        db = get_db()
        result = db.execute("SELECT * FROM users WHERE user_id = ?", user_id).first
        return result
    end
    def create_user(username,password_digest)
        db = get_db()
        result = db.execute("INSERT INTO users (username,user_role,pwdigest) VALUES (?,?,?)",username,"user",password_digest)
        return result
    end

    def update_user(name, email, phone, user_id)
        db = get_db()
        db.execute("UPDATE users SET name = ?, email = ?, phone = ? WHERE user_id = ?", name, email, phone, user_id)
    end

    def create_cat(name, breed_id, gender, age, size)
        db = get_db()
        db.execute("INSERT INTO cats (name, gender, age, size) VALUES (?,?,?,?)", name, gender, age, size)
    end

    def get_cat_info(cat_id)
        db = get_db()
        result = db.execute("SELECT * FROM cats WHERE cat_id = ?", cat_id).first
        return result
    end

    def create_breed_relationship(name, breed_id)
        db = get_db()
        cat_id = db.execute("SELECT cat_id FROM cats WHERE name = ?", name).first["cat_id"]
        db.execute("INSERT INTO cat_breed_relationship (cat_id, breed_id) VALUES (?, ?)", cat_id, breed_id)
    end

    def delete_cat(cat_id)
        db = get_db()
        db.execute("DELETE FROM cats WHERE cat_id = ?", cat_id) 
        db.execute("DELETE FROM user_cat_relationship WHERE cat_id = ?", cat_id)
        db.execute("DELETE FROM cat_breed_relationship WHERE cat_id = ?", cat_id)
    end

    def create_user_cat_relationship(cat_id,user_id)
        db = get_db()
        db.execute("INSERT INTO user_cat_relationship (user_id, cat_id) VALUES (?,?)", user_id, cat_id)
    end

    def destroy_user_cat_relationship(cat_id, user_id)
        db = get_db()
        db.execute("DELETE FROM user_cat_relationship WHERE cat_id = ? AND user_id = ?", cat_id, user_id)
    end

    def get_all_breeds()
        db = get_db()
        result = db.execute("SELECT * FROM cat_breeds")
        return result
    end

    def get_breed(cat_id)
        db = get_db()
        breed_id = db.execute("SELECT breed_id FROM cat_breed_relationship WHERE cat_id = ?", cat_id).first
        result = db.execute("SELECT breed_name FROM cat_breeds WHERE breed_id = ?", breed_id["breed_id"]).first
        return result
    end

    #Om det gått mindre än 15s sedan senaste failade loginförsök returneras true
    def cooldown_checker(previoustime,time)
        result = nil
        time_check = previoustime.to_i - time.to_i
        if time_check <= 15
            result = true
        else
            result = false
        end
        return result
    end

    #Om personen har loginförsök kvar returneras true
    def login_attempts(attempts)
        result = nil
        attempts_left = 4 - attempts.to_i
        if attempts_left <= 0
            result = false
        else
            result = true
        end
        return result
    end

    def validate_username1(username)
        if username =~ /[a-zA-Z0-9._]/
            characters = true
        else 
            characters = false
        end
        return characters
    end

    def validate_username2(username)
        if username =~ /(?=.{4,20}$)/
            characters_number = true
        else 
            characters_number = false
        end
        return characters_number
    end


end