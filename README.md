# Paperclip Nginx Upload

[![Build Status](https://travis-ci.org/tf/paperclip-nginx-upload.png?branch=master)](https://travis-ci.org/tf/paperclip-nginx-upload)

A Paperclip IOAdapter to handle file upload requests which have been
rewritten by the
[nginx upload module](https://github.com/vkholodkov/nginx-upload-module).

## WARNING

Alpha quality software. The code of this gem has been extracted from
our production setup. The gem itself though is still under development
and has not been used in production yet.

The gem evolved out of the discussion in the following paperclip
issue:

https://github.com/thoughtbot/paperclip/issues/1396

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-nginx-upload'

## Usage

Configure nginx to parse your upload requests. There is an example
nginx configuration snippet in `examples/nginx.conf`.

```ruby
    module YourApp
      class Application < Rails::Application
        # Other code...

        config.paperclip_nginx_upload = {
          :tmp_file_whitelist => ['/tmp/nginx_uploads/**']
        }
      end
    end    
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
