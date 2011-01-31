module AuthlogicConnect::Common
end

require File.dirname(__FILE__) + "/common/state"
require File.dirname(__FILE__) + "/common/variables"
require File.dirname(__FILE__) + "/common/login"
require File.dirname(__FILE__) + "/common/session"

ActiveRecord::Base.send(:include, AuthlogicConnect::Common::Login)
Authlogic::Session::Base.send(:include, AuthlogicConnect::Common::Session)
