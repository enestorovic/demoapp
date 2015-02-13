worker_processes 2
user "rails"
working_directory "/home/rails/demoapp/current"
listen "unix:tmp/sockets/unicorn.sock" , :backlog => 1024

pidfile = "tmp/pids/unicorn.pid"
pid pidfile

timeout 60

stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

preload_app true

before_fork do |server, worker|
	old_pid = "#{pidfile}.oldbin"
	if File.exists?(old_pid) and server.pid != old_pid
		begin
			Process.kill('QUIT', File.read(old_pid).to_i)
		rescue Errno::ENOENT, Errno::ERSCH
			
		end
	end
	
	if defined?(ActiveRecord::Base)
		ActiveRecord::Base.connection_handler.clear_all_connections!
	end
	
end

after_form do |server, worker|
	defined?(ActiveRecord::Base) and
		ActiveRecord::Base.establish_connection
end