require 'net/ssh/simple'

module LegoEv3
  class Uploader
    def initialize(host, user, password, project)
      @host = host
      @user = user
      @password = password
      @project = project
    end

    def upload
      Net::SSH::Simple.sync({ host_name: @host, user: @user, password: @password, timeout: 600 }) do
        puts "Creating folder #{project_folder}..."
        ssh('ev3', "rm -rf #{project_folder}")

        puts "Upload project..."
        upload_folder(@project)

        puts "Downloading dependencies from Gemfile..."
        ssh('ev3', "cd #{project_folder} && gem install bundler && bundle install")
      end
    end

    private

    def upload_file(src_relative, dst_relative)
      file_remote = "#{project_folder}/#{dst_relative}"
      puts "Sending #{src_relative} to #{file_remote}..."
      scp_put('ev3', src_relative, file_remote)
    end

    def upload_folder(src_relative)
      folders = Dir.glob("#{src_relative}/**/*/")
      files = Dir.glob("#{src_relative}/**/*").select { |f| File.file?(f) }

      folders.each do |path_relative|
        folder_remote = "#{project_folder}/#{path_relative}"
        puts "Creating folder #{folder_remote}..."
        ssh('ev3', "mkdir -p #{folder_remote}")
      end

      files.each do |path_relative|
        upload_file(path_relative, path_relative)
      end
    end

    def project_folder
      "/home/#{@project.split('/').last}"
    end
  end
end
