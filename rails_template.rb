# My version of an app template, modified by James Cox (imajes)
# SUPER DARING APP TEMPLATE 1.0 - By Peter Cooper

# Delete unnecessary files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm public/images/rails.png"
run "rm -f public/javascripts/*"

# Download JQuery
run "curl -s -L http://jqueryjs.googlecode.com/files/jquery-1.3.1.min.js > public/javascripts/jquery.js"
run "curl -s -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# Set up git repository
git :init
git :add => '.'

# Copy database.yml for distribution use
run "cp config/database.yml config/database.yml.example"

# Set up .gitignore files
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
vendor/rails
END

# Set up session store initializer
initializer 'session_store.rb', <<-END
ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
ActionController::Base.session_store = :active_record_store
  END

# Install plugins
## Those that relate to testing
# RSpec is the original Behaviour Driven Development framework for Ruby.
plugin 'rspec', :git => "git://github.com/dchelimsky/rspec.git"

# RSpec's official Ruby on Rails plugin  
plugin 'rspec-rails', :git => "git://github.com/dchelimsky/rspec-rails.git"

# Fixture replacement for focused and readable tests.
plugin 'object_daddy', :git => "git://github.com/flogic/object_daddy.git"

# BDD that talks to domain experts first and code 2nd
plugin 'cucumber', :git => "git://github.com/aslakhellesoy/cucumber.git"

generate("rspec")
generate("cucumber")
gem 'faker'

## setup for the win
inside ('spec') { 
  run "mkdir exemplars"
  run "rm -rf fixtures"
  run "rm spec_helper.rb spec.opts rcov.opts"
  run "curl -sL http://github.com/imajes/rails-template/raw/master/spec_helper.rb > spec_helper.rb"
  run "curl -sL http://github.com/imajes/rails-template/raw/master/rcov.opts > rcov.opts"
  run "curl -sL http://github.com/imajes/rails-template/raw/master/spec.opts > spec.opts"
  
}

## Potentially Useful 
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
plugin 'hoptoad_notifier', :git => 'git://github.com/thoughtbot/hoptoad_notifier.git'

## user related
if yes?("Will this app have authenticated users?")
  plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git'
  plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
  plugin 'aasm', :git => 'git://github.com/rubyist/aasm.git'
  gem 'ruby-openid', :lib => 'openid'  
  generate("authenticated", "user session")
  generate("roles", "Role User")
end

#Subdomains: http://railscasts.com/episodes/123-subdomains
if yes?("Will this app require a sub-domain per account ?")
  plugin 'subdomain-fu', :git => 'git://github.com/mbleigh/subdomain-fu.git'

end

if yes?("OpenID Support?")
  plugin 'open_id_authentication', :git => 'git://github.com/rails/open_id_authentication.git'
  rake('open_id_authentication:db:create')
end

# tags
if yes?("Do you want tags with that?")
  plugin 'acts_as_taggable_redux', :git => 'git://github.com/geemus/acts_as_taggable_redux.git'
  rake('acts_as_taggable:db:create')
end

# require some gems
if yes?("Want to require a bunch of useful gems?")
  gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
  gem 'RedCloth', :lib => 'redcloth'
end

# add nifty layout (generators)
if yes?("Want to add layout (nifty)?")
  generate :nifty_layout
end

# Final install steps
rake('gems:install', :sudo => true)
rake('db:sessions:create')
rake('db:migrate')

first = ask("What'll be your first action?")
generate(:model, first)

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'First POST!'"

# Success!
puts "SUCCESS! - remember to setup hoptoad with the following:"
puts "HoptoadNotifier.configure do |config|
  config.api_key = '1234567890abcdef'
end"
