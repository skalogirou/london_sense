Rails.application.routes.draw do
	match 'london_sense/callback', :to => "pages#digital_town_redirect", :via => [:post, :get]
	match 'london_sense', :to => "pages#digital_town_login", :via => [:post, :get]
	match 'london_sense/logout', :to => "pages#digital_town_logout", :via => [:get]

end
