case ENV['RAILS_ENV']
when 'production'
  execute 'bundle' do
    command <<-EOF
      bundle config unset without
      bundle config set without 'development test'
      sudo bundle install -j2
    EOF
  end
else
  execute 'bundle' do
    command <<-EOF
      bundle config unset without
      sudo bundle install -j2
    EOF
  end
end
