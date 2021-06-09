require "fileutils"
require "pathname"
require "net/http"
require "uri"
require "json"

module Planetscale
  class Installer
    class << self
      def run(install_dir)
        install_pathname = Pathname(install_dir)
        bin_dir = install_pathname.join("bin")

        FileUtils.mkdir_p(bin_dir)
        Dir.chdir(bin_dir) do
          install(bin_dir)
          setup_profile_d(install_pathname, bin_dir)
        end
      end

      private

      def install(dir)
        puts "---- Installing pscale\n"

        process = nil

        trap("CHLD") do
          while !process.nil? && pid = Process.waitpid(-1, Process::WNOHANG)  do
            process = nil
            puts "---- pscale added to #{dir}\n"
          end
        end

        process = Process.spawn("#{curl_command} - | #{untar_command(dir)}")
        puts "---- Downloading and extracting pscale from #{release_url}"

        sleep 0.1 while !process.nil?
      end

      def untar_command(dir)
        "tar x -z -C #{dir} --transform=s/.*/pscale/"
      end

      def curl_command
        "curl -L --fail --retry 5 --retry-delay 1 --connect-timeout #{curl_connect_timeout_in_seconds} --max-time #{curl_timeout_in_seconds} #{release_url} -s -o"
      end

      def curl_timeout_in_seconds
        ENV["CURL_TIMEOUT"] || 30
      end

      def curl_connect_timeout_in_seconds
        ENV["CURL_CONNECT_TIMEOUT"] || 3
      end

      def release_url
        @release_url ||= "https://github.com/planetscale/cli/releases/download/v#{version}/pscale_#{version}_linux_amd64.tar.gz"
      end

      def version
        return ENV["PLANETSCALE_CLI_VERSION"] if ENV["PLANETSCALE_CLI_VERSION"]

        uri = URI.parse("https://api.github.com/repos/planetscale/cli/releases/latest")
        response = Net::HTTP.get_response(uri)

        if response.code == "200"
          JSON.parse(response.body)["tag_name"].gsub("v", "")
        else
          "0.45.0"
        end
      end

      def setup_profile_d(install_pathname, bin_dir)
        profile_path = install_pathname.join(".profile.d/heroku-buildpack-planetscale.sh")
        profile_path.parent.mkpath

        File.open(profile_path, "w") do |file|
          file.puts "# add pscale to the path"
          file.puts "export PATH=$PATH:$HOME/#{bin_dir.basename}"
        end
        puts "----- Created profile.d script at #{profile_path}"
      end
    end
  end
end