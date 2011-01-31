class CreateLogins < ActiveRecord::Migration
  def self.up
    create_table :logins do |t|
      # authlogic
      t.timestamps
      t.string :login, :null => false
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token, :null => false
      t.integer :login_count, :default => 0, :null => false
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      # authlogic-connect
      t.string :openid_identifier # should be a token, later...
      t.integer :active_token_id
    end
    
    add_index :logins, :login
    add_index :logins, :persistence_token
    add_index :logins, :last_request_at
    add_index :logins, :active_token_id
  end

  def self.down
    drop_table :logins
  end
end
