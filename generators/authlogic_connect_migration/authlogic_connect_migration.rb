class AuthlogicConnectMigrationGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/create_logins', :migration_file_name => "create_logins"
      m.migration_template 'migration.rb', 'db/create_sessions', :migration_file_name => "create_sessions"
      m.migration_template 'migration.rb', 'db/create_tokens', :migration_file_name => "create_tokens"
    end
  end
end
