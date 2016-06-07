# CSC 667 Web Server Project

Local web server written in Ruby that serves static resources.

Responds to HTTP requests with status codes 200, 201, 204, 400, 401, 403, 404, or 500.

Documentation: https://docs.google.com/document/d/1ze8yF1-jbCxfrrQZVcLtrHyFYKSKanyWG1k4zNmgqeg/edit?usp=sharing

## Getting Started

In order to run the web server, you'll have to modify the filepaths within
the `httpd.conf` and `.htaccess` files to match your directory structure.

Within the rubyserver/ directory, to run the web server:
```
ruby server.rb
```
Then in a browser enter:
```
localhost:port/file_path
```
Where `port` is an arbitrarily chosen port number specified within the `httpd.conf` file,
and `file_path` is a file or directory within the server's filepath, e.g. `chomp.gif`.

To access files within the protected directory, use these credentials:
```
username: luis
password: estrada
```

##### Known issues:
* Doesn't work well with Chromium browser on Ubuntu (use Mozilla Firefox instead)
