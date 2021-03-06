require 'grape-swagger'

module API	
	module V2
		class Base < Grape::API
			version 'v2'

			mount API::V2::Products

			before do
	      error!("401 Unauthorized", 401) unless authenticated
	    end

	    before do 
	    	error!("No current user", 401) unless authenticated
	    end

	    helpers do
	      # def authenticated
	      #   user = User.find_by_email(params[:email])
	      #   user && user.valid_password?(params[:password])
	      # end

	      # def authenticated # or like, http://funonrails.com/2014/03/api-authentication-using-devise-token/
	      # 	user_key = User.find_by_key(params:key) # TODO field for key, hash username + API key
	      # 	user_key != nil # TODO check error response for this
	      # end
	      def authenticated
	      	true # TMP
	      end

	      # def current_user
       #  	return nil if ENV['rack.session'][:user_id].nil?
       #  	@current_user ||= User.get(ENV['rack.session'][:user_id])
      	# end
      
      	# def current_user=(user)
       #  	ENV['rack.session'][:user_id] = user.id unless user
       #  	@current_user = user
      	# end
		  	
    	end

		end
	end
end