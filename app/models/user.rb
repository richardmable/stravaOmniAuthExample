class User < ActiveRecord::Base
	has_one :profile
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  def self.from_omniauth(auth)
      # save this to the database, this will be the token that is sent to update a user's data
      # probably should be in another table connected to the user that could be called StravaAuthData
        puts "INFO IS #{auth.credentials.token.inspect}"

    # this is saying where the user has provider Strava, and the matching UID, pull the first return or create it
    # the provided block is only executed if running the create function
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    	user.email = auth.info.email
    	user.password = Devise.friendly_token[0,20]
      puts "INFO IS #{auth.info.inspect}"
     p = Profile.create(name: auth.info.name)
     user.profile = p
  	end
   end

	def self.new_with_session(params, session)
	    super.tap do |user|
	      if data = session["devise.strava_data"] && session["devise.strava_data"]["extra"]["raw_info"]
	        user.email = data["email"] if user.email.blank?
	      end
	    end
	  end
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:strava]
end
