require_relative 'models'

require 'roda'
require 'tilt/sass'
require 'sidekiq'
require 'pry'

app_paths = Pathname(__FILE__).dirname.join("lib/services").realpath.join("**/*")
Dir[app_paths].each do |path|
  require path
end

class AppName < Roda
  plugin :json_parser
  plugin :default_headers,
    'Content-Type'=>'application/json',
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

  plugin :flash
  plugin :assets, css: 'app.scss', css_opts: {style: :compressed, cache: false}, timestamp_paths: true
  plugin :render, escape: true
  plugin :public
  plugin :multi_route

  plugin :not_found do
    @page_title = "File Not Found"
    view(:content=>"")
  end

  plugin :error_handler do |e|
      @page_title = "Internal Server Error"
      $stderr.print "#{e.class}: #{e.message}\n"
      $stderr.puts e.backtrace
      view(:content=>"")
  end

  plugin :sessions,
    key: '_AppName.session',
    #cookie_options: {secure: ENV['RACK_ENV'] != 'test'}, # Uncomment if only allowing https:// access
    secret: ENV.send((ENV['RACK_ENV'] == 'development' ? :[] : :delete), 'APP_NAME_SESSION_SECRET')

  Unreloader.require('routes'){}

  route do |r|
    r.public
    r.assets
    r.multi_route

    r.root do
      view 'index'
    end
  end
end
