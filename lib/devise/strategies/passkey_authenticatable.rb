module Devise  
    module Strategies 
        class PasskeyAuthenticatable < Authenticatable
            def valid?
                params[:token]
            end

            def authenticate!
                token = params[:token]
                res = Excon.post(ENV['BITWARDEN_PASSWORDLESS_API_URL'] + '/signin/verify', 
                    body: JSON.generate({
                        token: token
                    }),
                    headers: {
                        "ApiSecret" => ENV["BITWARDEN_PASSWORDLESS_API_PRIVATE_KEY"],
                        "Content-Type" => "application/json"
                    }
                )
                
                json = JSON.parse(res.body)
                if json["success"]
                    success!(User.find(json["userId"]))
                else
                    fail!(:invalid_login)
                end
            end
        end
    end
end

Warden::Strategies.add(:passkey_authenticatable, Devise::Strategies::PasskeyAuthenticatable)