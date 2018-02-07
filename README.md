# Web Server

Multithreaded static web server written in Ruby, which was developed to learn
about the HTTP protocol and the underpinnings of the Ruby on Rails framework.

Creating a connection through sockets, the server reads and parses HTTP
requests from a client, performs a series of operations, and returns an HTTP
response with the appropriate status code and resource (if applicable).

Responds to local HTTP requests with status codes 200, 201, 204, 400, 401, 403, 404, and 500.

## Getting Started

In order to run the web server, you'll have to modify the filepaths within
the `httpd.conf` and `.htaccess` files to match your directory structure.

Within the rubyserver/ directory, run the server using:
```
ruby server.rb
```
Then in a browser enter:
```
localhost:port/file_path
```
Where `port` is an arbitrarily chosen port number specified within the `httpd.conf` file,
and `file_path` is a file or directory within the server's filesystem, e.g. `chomp.gif`.

To access files within the protected directory, use these credentials:
```
username: luis
password: estrada
```

#### Technologies:
* Ruby, HTML
* Tools: Git, GitHub

#### See more:
* [Original documentation](https://goo.gl/0d0PWk)

##### Known issues:
* Doesn't work well with the Chromium browser on Ubuntu (use Mozilla Firefox instead).
