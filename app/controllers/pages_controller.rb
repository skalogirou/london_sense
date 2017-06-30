[class PagesController < ApplicationController
	def digital_town_redirect
		if params[:code]
			client_secret = DIGITALTOWN_CLIENT_SECRET
			client_id = DIGITALTOWN_CLIENT_ID
			url = "https://api.digitaltown.com/sso/token"
			data = {:grant_type => "authorization_code", :redirect_uri => "https://callcntr.theansr.com/london_sense/callback", :code => params[:code], :client_id => client_id, :client_secret => client_secret}
			request = HttpRequest.new({:url => url })
			r = request.post data
			response = JSON.parse r
			session[:access_token] = response["access_token"]
			url = "https://api.digitaltown.com/sso/users"
			request_user = HttpRequest.new({:url => url, :headers => {:authorization => "Bearer #{response["access_token"]}"}})
			r = request_user.get
			user = JSON.parse r
			Rails.logger.info user.to_json
			redirect_url = "http://london.sense.city/scwebsubmit.html?name=#{user["first_name"]}%0A#{user["last_name"]}&email=#{user["email"]}"
			redirect_to redirect_url and return
			#render :json => {:status => "OK", :token => response}
		else
			session[:access_token] = params["accessToken"]
			url = "https://api.digitaltown.com/sso/users"
			request_user = HttpRequest.new({:url => url, :headers => {:authorization => "Bearer #{session["access_token"]}"}})
			r = request_user.get
			user = JSON.parse r
			Rails.logger.info user.to_json
			redirect_url = "http://london.sense.city/scwebsubmit.html?name=#{user["first_name"]}%0A#{user["last_name"]}&email=#{user["email"]}"
			redirect_to redirect_url and return
			#render :json => {:status => "OK"}
		end
	end
	def digital_town_login
		unless session[:access_token].nil?
			access_token = session[:access_token]
			url = "https://api.digitaltown.com/sso/users"
			request_user = HttpRequest.new({:url => url, :headers => {:authorization => "Bearer #{access_token}"}})
			r = request_user.get
			user = JSON.parse r
			if user["email"].nil?
				@login_url = "https://v1-sso-api.digitaltown.com/oauth/authorize?response_type=code&client_id=#{client_id}&redirect_uri=https://callcntr.theansr.com/london_sense/callback"
				@register_url = "https://v1-sso-api.digitaltown.com/register?callback=https://callcntr.theansr.com/london_sense/callback"
				render :digital_town, :layout => "london_sense"
			else
				redirect_url = "http://london.sense.city/scwebsubmit.html?name=#{user["first_name"]}%0A#{user["last_name"]}&email=#{user["email"]}"
				redirect_to redirect_url and return
			end
		else
			@login_url = "https://v1-sso-api.digitaltown.com/oauth/authorize?response_type=code&client_id=#{client_id}&redirect_uri=https://callcntr.theansr.com/london_sense/callback"
			@register_url = "https://v1-sso-api.digitaltown.com/register?callback=https://callcntr.theansr.com/london_sense/callback"
			render :digital_town, :layout => "london_sense"
		end
	end
	def digital_town_logout
		session[:access_token] = nil
		redirect_to london_sense_path
	end
end

