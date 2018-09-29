#URL Shortener

Simple url shortener written on ruby using [em-hiredis](https://github.com/mloughran/em-hiredis) and [sinatra](https://github.com/sinatra/sinatra).
Needs to [redis](https://redis.io) be installed.

####Run with:

```
$ bundle
$ rake
```

####Usage example:

```
$ curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"longUrl": "https://google.com"}' \
  http://localhost:1234/
```

####Answer:

```
{"url":"http://localhost:1234/1X8jx44s"}
```

####Trying link:
```
$ curl -i http://localhost:1234/1X8jx44s

HTTP/1.1 301 Moved Permanently
Content-Type: text/html;charset=utf-8
Location: https://google.com
Content-Length: 0
Connection: keep-alive
Server: thin
```