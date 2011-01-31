module AuthlogicConnect::Oauth
  # This module is responsible for adding oauth
  # to the Authlogic::Session::Base class.
  module Session
    def self.included(base)
      base.class_eval do
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      include Process

      def self.included(klass)
        klass.class_eval do
          validate :validate_by_oauth, :if => :authenticating_with_oauth?
        end
      end
      
      # Hooks into credentials so that you can pass a login who has already has an oauth access token.
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        self.record = hash[:priority_record] if !hash.nil? && hash.key?(:priority_record)
      end

      def record=(record)
        @record = record
      end

    private
      
      def complete_oauth_transaction
        if @record
          self.attempted_record = record
        else
          # this generated token is always the same for a login!
          # this is searching with login.find ...
          # attempted_record is part of AuthLogic
          hash = oauth_token_and_secret
          token = token_class.find_by_key_or_token(hash[:key], hash[:token], :include => [:login]) # some weird error if I leave out the include)
          if token
            self.attempted_record = token.login
            self.attempted_record.active_token = token
          elsif auto_register?            
            tmp_token = token_class.new(hash)
            email = ''
            if tmp_token.type == "GoogleToken"
              email = tmp_token.key
            elsif tmp_token.type == "FacebookToken"
              facebook = JSON.parse(tmp_token.get("/me"))
              email = facebook["email"]
            else
              #TODO: have to check for the email from other authentication type.
            end
            # We do not want to create a new login everytime someone access different authenticatino system with the same email field.
            existing_login = email.blank? ? nil : klass.find_by_email(email)
            # FacebookToken is created multiple times, if the login removes the application and then adds it back on their facebook account. 
            # We just want to update the existing facebook token with the new token information.
            old_facebook_token = nil
            if existing_login
              self.attempted_record = existing_login
              # Get the old facebook token from the database for the existing_login if he/she signed in before via facebook
              old_facebook_token    = existing_login.access_tokens.where(:login_id => existing_login.id, :type => "FacebookToken").first if (tmp_token.type == "FacebookToken")
            else
              self.attempted_record = klass.new
              self.attempted_record.email = email unless email.blank?
            end
            if old_facebook_token
              old_facebook_token.update_attributes({:token => tmp_token.token, :secret => tmp_token.secret})
              self.attempted_record.active_token = old_facebook_token
              self.attempted_record.active       = true
            else
              self.attempted_record.access_tokens << tmp_token
              self.attempted_record.active_token = tmp_token
              self.attempted_record.active       = true
            end
            self.attempted_record.save
          else
            auth_session[:_key] = hash[:key]
            auth_session[:_token] = hash[:token]
            auth_session[:_secret] = hash[:secret]
          end
        end

        if !attempted_record
          errors.add(:login, "Could not find login in our database, have you registered with your oauth account?")
        end
      end
    end
  end
end
