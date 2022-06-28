# Paperclip Nginx Upload

[![Gem Version](https://badge.fury.io/rb/paperclip-nginx-upload.png)](http://badge.fury.io/rb/paperclip-nginx-upload)
[![Build Status](https://github.com/tf/paperclip-nginx-upload/actions/workflows/tests.yml/badge.svg)](https://github.com/tf/paperclip-nginx-upload/actions/workflows/tests.yml)

A Paperclip IOAdapter to handle file upload requests which have been
rewritten by the
[nginx upload module](https://github.com/vkholodkov/nginx-upload-module).

The gem evolved out of the discussion in the following paperclip
issue:
https://github.com/thoughtbot/paperclip/issues/1396

## Motivation

Nginx is much faster when it comes to parsing file uploads from the
body of HTTP requests.  We do not want to occupy our Rails processes
with this tasks.  Using the
[nginx upload module](https://github.com/vkholodkov/nginx-upload-module),
upload request can be rewritten to contain the path of a temp file
parsed from the request body before they are passed to our Rails app.

## Installation

Choose one from two options and add line to your application's Gemfile:

1.) with [paperclip](https://github.com/thoughtbot/paperclip) dependency, use:

    gem 'paperclip-nginx-upload', '~> 1.0'

2.) with [kt-paperclip](https://github.com/kreeti/kt-paperclip) dependency, use:

    gem 'paperclip-nginx-upload', '~> 2.0'

## Usage

Configure nginx to parse your upload requests. There is an example
nginx configuration snippet in `examples/nginx.conf`.

Add an initializer to configure the gem:

```ruby
 # config/intializers/paperclip_nginx_upload.rb
 require 'paperclip/nginx/upload'

 Paperclip::Nginx::Upload::IOAdapter.default_options.merge!(
   # location where nginx places file uploads
   tmp_path_whitelist: ['/tmp/nginx_uploads/**'],

   # Change this option to true to move temp files created
   # by nginx to the paperclip tmp file location. By default
   # files are copied.
   move_tempfile: false
 )
```

The adapter is a drop in replacement. When using strong parameters,
you only have to make sure the param containing the upload can also be
a hash of values:

```ruby
 class User
   has_attached_file :avatar
 end

 class UsersController < ApplicationController
   def update
     @user.update_attributes(user_params)
   end

   def user_params
     params.require(:user)
      # in production avatar will be a hash generated by nginx
      .permit(avatar: [:tmp_path, :original_name, :content_type])

      # in development we want to permit the uploaded file itself
      .merge(params.require(:user).permit(:avatar))
   end
 end
```

## Security Considerations

Assume an upload request contains a form field named
`user[avatar]`. Given the nginx configuration from
`examples/nginx.conf`, the request is rewritten to contain the
following three form fields instead:

* `user[avatar][original_name]`
* `user[avatar][conten_type]`
* `user[avatar][tmp_path]`

By using this gem, you basically tell your app to accept paths to
local files in the `tmp_path` param and move them around the
file system. Nginx ensures that these parameters can not be passed in
from the outside, preventing an attacker from passing `/etc/passwd` as
`tmp_path` and having it delivered to him as his own upload
later on.

Still, if you forget to configure the nginx-upload-module correctly
for one of your upload end points, this could become a threat. This is
especially dangerous when not using strong parameters. While, as seen
above, the nested hash has to be permitted explicitly, methods
assigning attachments directly might be open to attacks:

```ruby
 @user.avatar = params[:avatar]
```

Therefore the paperclip-nginx-upload adapter only accepts tmp files
from locations matching an entry in the `tmp_path_whitelist`. That way
an attacker will only be able to access running uploads of other
visitors of the site. He still would have to guess the random file
names chosen by nginx, which seems rather unfeasable.

## Move vs Copy

By default, temp files created by ngninx are copied before passing
them to Paperclip. This ensures proper file ownership. When your nginx
runs as the same user as your rails processes, it might be sufficient
to simply move the file. Depending on your file system, this might be
a significant performance gain. In that case set `move_tempfile` to
`true`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
