require 'net/http'
require 'net/https'

class HttpRequest
	include ActiveModel::AttributeMethods
	attr_accessor :url, :data, :ssl, :method, :headers, :body
	
	def initialize(attributes = {})
		attributes.each do |name, value|
			send("#{name}=", value)
		end
	end

	def post(_data = nil, _body = nil)
		@method = 'post'
		@data = _data if _data
		@body = _body if _body
		self.send_request
	end

	def get(_data = nil)
		@method = 'get'
		@data = _data if _data
		self.send_request
	end
	def put(_data = nil)
		@method = 'put'
		@data = _data if _data
		self.send_request
	end

	def send_request
		#@remote_ip = request.env["REMOTE_ADDR"]
		url = URI.parse(@url)
		if @method == "post"
			req = Net::HTTP::Post.new("#{url.path}?#{url.query}")
		elsif @method == "get"
			req = Net::HTTP::Get.new("#{url.path}?#{url.query}")
		elsif @method == "put"
			req = Net::HTTP::Put.new("#{url.path}?#{url.query}")
		end
		if @credentials
			req.basic_auth @credentials[:username], @credentials[:password]
		end
		if @headers 
			@headers.each do |k,v|
				#req.add_field(k,v)
				req["#{k}"] = "#{v}"
			end
		end
		if @data
			#data[:data].merge!({:remote_ip => @remote_ip})
			req.form_data = @data
			#else
			#  data[:data] = {:remote_ip => @remote_ip}
		end
		if @body
                        req.body = @body
                end
		if url.scheme == "http"
			http = Net::HTTP.new(url.host, url.port)
		elsif url.scheme == "https"
			http = Net::HTTP.new(url.host, 443)
			http.use_ssl = true
			if @ssl && @ssl[:ca_file]
				http.ca_file = @ssl[:ca_file]
				http.verify_mode = OpenSSL::SSL::VERIFY_PEER   
			else
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
		end
		
		res = http.request(req)
		return res.body
	end
end
