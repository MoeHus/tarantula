# Installation instructions

## Preamble
Unix based server reccommended. 
All commands are specified for Ubuntu 12.04.
Provided installation process was tested on Ubuntu 12.04.

You can use standard installation instructions from [here](https://github.com/prove/tarantula).  
The differences are:
- proxy server used (current procedure is for nginx)
- current procedure is for advanced users
- after standard installation you'll need to perform following [additional actions](https://getsatisfaction.com/prove/topics/jira_link) to intgrate with oracle hosted jira.   

## Installation process

1. Install rmv on your system, details can be found [here](https://rvm.io/rvm/install/)
2. Install ruby with rvm (1.9.3 recommended) 
3. Install bundler:     rvm 1.9.3 do gem install bundler
4. Install git on your system, details can be found [here](http://git-scm.com/book/en/Getting-Started-Installing-Git)
5. Create directory to hold the application code (will be reffered to as APPS)
6. CD to $APPS
7. Clone source code of the application: `git clone git@github.com:evgeniy-khatko/tarantula.git`  
8. CD to $APPS/tarantula
9. Install required ruby gems to run the app:  
**if you don't plan to integrate Tarantula with oracle hosted jira**  
  `bundle install --without development oracle_enabled`   
**if you plan to integrate Tarantula with oracle hosted jira**  
  install oracle development libraries with [oracle instant client](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html)   
  `bundle install --without development`   make sure that bundle install finishes successfully  
10. Install mysql
11. Provided you have mysql user with admin privileges => user:secret
12. add following lines to $APPS/tarantula/config/database.yml:  
      <% get_socket = lambda{ ["/opt/local/var/run/mysql5/mysqld.sock",   
                               "/opt/lampp/var/mysql/mysql.sock",  
                               "/var/run/mysqld/mysqld.sock",  
                               "/var/lib/mysql/mysql.sock"].\  
                              detect{|p| File.exists?(p)} } %>  
      production:  
          adapter: mysql2  
          database: tarantula  
          username: user  
          password: secret  
          host: localhost   
          encoding: utf8  
      socket: <%= get_socket.call %>    
13. run following command to finish tarantula installation (assuming you're in $APPS/tarantula)       
       `RAILS_ENV=production bundle exec rake tarantula:install => follow instruction`         
14. run following command to start delayed jobs:         
        `RAILS_ENV=production bundle exec rake tarantula:jobs:work (assuming you're in $APPS\/tarantula)`         
15. test your installation trying to start server with following command:     
        `RAILS_ENV=production bundle exec rails s` (assuming you're in $APPS\/tarantula)            
*Proceed to next steps if everything is OK*
16. install nginx server on your system
17. install nginx passenger module with following command:     passenger-install-nginx-module
18. configure nginx to use passenger module with adding following commands to your nginx.conf:  
                http {  
                    passenger_root /path/to/rvm/.rvm/gems/ruby-1.9.3-p286/gems/passenger-3.0.18;  
                    passenger_ruby path/to/rvm/.rvm/wrappers/ruby-1.9.3-p286/ruby;  
                    passenger_default_user your_server_user;  
                    passenger_default_group your_server_group;  
                    include       mime.types;  
                    default_type  application/octet-stream;  
                    sendfile        on;  
                    keepalive_timeout  65;  
                  server {  
                    listen 80;  
                    server_name tarantula.myserver.com;  
                    root $APPS/tarantula/public;   # <--- be sure to point to 'public'!  
                    passenger_enabled on;  
                    charset utf-8;  
                  }  
                }  
19. navigate to nginx listening port and test your installation

P.S.
it's recommended to create a capistrano task to automate server code update
