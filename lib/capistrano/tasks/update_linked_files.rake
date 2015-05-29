namespace :deploy do

  desc 'Upload linked_files from local server'
  task :update_linked_files do
    linked_files(shared_path).each do |file|
      upload File.join("/var/apps/#{fetch(:application)}", file), File.join(shared_path, file)
    end
  end

end

after 'deploy:check:make_linked_dirs', 'deploy:update_linked_files'
