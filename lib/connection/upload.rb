require 'net/ssh/simple'

module LegoEv3
  class Uploader
    def initialize(host, user, password, project)
      @host = host
      @user = user
      @password = password
      @local_project_path = Pathname.new(project).realpath.to_s
    end

    def upload
      Net::SSH::Simple.sync({ host_name: @host, user: @user, password: @password, timeout: 600 }) do
        puts "Removing previous folder #{remote_project_path}..."
        ssh('ev3', "rm -rf #{remote_project_path}/**/*")

        puts "Creating folder #{remote_project_path}..."
        ssh('ev3', "mkdir -p #{remote_project_path}")

        puts "Upload project..."
        upload_folder(@local_project_path)

        # Takes too much time, better to do it once on the brick.
        #puts "Installing lib..."
        #ssh('ev3', "cd #{remote_project_path} && gem install lego_ev3")

        # Takes too much time, better to do it once on the brick.
        #puts "Downloading dependencies from Gemfile..."
        #ssh('ev3', "cd #{remote_project_path} && gem install bundler && bundle install")
      end
    end

    private

    def upload_file(src, dst_relative)
      file_remote = "#{remote_project_path}/#{dst_relative}"
      puts "Sending #{src} to #{file_remote}..."
      scp_put('ev3', src, file_remote)
    end

    def upload_folder(src)
      folders = Dir.glob("#{src}/**/*/")
      files = Dir.glob("#{src}/**/*").select { |f| File.file?(f) }

      folders.each do |path|
        folder_remote = "#{remote_project_path}/#{local_abs_to_rel_path(path)}"
        puts "Creating folder #{folder_remote}..."
        ssh('ev3', "mkdir -p #{folder_remote}")
      end

      files.each do |path|
        upload_file(path, local_abs_to_rel_path(path))
      end
    end

    def local_abs_to_rel_path(path)
      path.gsub(/^#{@local_project_path}\//, '')
    end

    def remote_project_path
      "/home/#{@local_project_path.split('/').last}"
    end
  end
end
