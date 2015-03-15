require 'socket'
require 'json'

server = TCPServer.open(2000)

loop {
	client = server.accept
	request = client.read_nonblock(256)
	header, body = request.split("\r\n\r\n", 2)
	method = header.split[0]
	filename = header.split[1][1..-1]
	
	if File.exists?(filename)
		f = File.read(filename)
		if method == "GET"
			client.print "HTTP/1.0 200 OK\r\nDate: #{Time.now.ctime}\r\nContent-Type: text/html\r\nContent-Length: #{File.size(filename)}\r\n\r\n"
			client.puts(f)
		elsif method == "POST"
			params = JSON.parse(body)
			user_display = "<ul><li>Name: #{params['user']['name']}</li><li>Email: #{params['user']['email']}</li><li>Age: #{params['user']['age']}</li></ul>"
			client.print "HTTP/1.0 200 OK\r\nDate: #{Time.now.ctime}\r\nContent-Type: text/html\r\nContent-Length: #{user_display.size}\r\n\r\n"
			client.puts f.gsub('<%= yield %>', user_display)
		end
	else
		client.puts "HTTP/1.0 404 Not Found\r\n\r\n(404) The requested file could not be found."	
	end

	client.close
}