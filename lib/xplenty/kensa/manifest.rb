require 'securerandom'

module Xplenty
  module Kensa
    class Manifest
      REGIONS = %w(
        amazon-web-services::us-east-1 
        amazon-web-services::us-west-2
        amazon-web-services::eu-west-1
        rackspace::dfw 
        rackspace::ord
        soft-layer::dal05
        soft-layer::ams01
        soft-layer::sng01
      )

      def initialize(options = {})
        @method   = options.fetch(:method, 'post').to_sym
        @filename = options[:filename]
        @options  = options
      end

      def skeleton_json
        @password = generate_password(16)
        @port     = @options[:foreman] ? 5000 : 4567
        (@method == :get) ? get_skeleton : post_skeleton
      end

      def get_skeleton
        <<-JSON
{
  "id": "myaddon",
  "api": {
    "config_vars": [ "MYADDON_URL" ],
    "regions": [ "amazon-web-services::us-east-1" ],
    "password": "#{@password}",#{ sso_key }
    "production": "https://yourapp.com/",
    "test": "http://localhost:#{@port}/"
  }
}
JSON
      end

      def post_skeleton
        <<-JSON
{
  "id": "myaddon",
  "api": {
    "config_vars": [ "MYADDON_URL" ],
    "regions": [ "amazon-web-services::us-east-1" ],
    "password": "#{@password}",#{ sso_key }
    "production": {
      "base_url": "https://yourapp.com/xplenty/resources",
      "sso_url": "https://yourapp.com/sso/login"
    },
    "test": {
      "base_url": "http://localhost:#{@port}/xplenty/resources",
      "sso_url": "http://localhost:#{@port}/sso/login"
    }
  }
}
JSON

      end

      def foreman
        <<-ENV
SSO_SALT=#{@sso_salt}
XPLENTY_USERNAME=myaddon
XPLENTY_PASSWORD=#{@password}
ENV
      end

      def skeleton
        OkJson.decode skeleton_json
      end

      def write
        File.open(@filename, 'w') { |f| f << skeleton_json }
        File.open('.env', 'w') { |f| f << foreman } if @options[:foreman]
      end

      private

        def sso_key
          @sso_salt = generate_password(16)
          unless @options[:sso] === false
            %{\n    "sso_salt": "#{@sso_salt}",}
          end
        end

        def generate_password(size=8)
          SecureRandom.hex(size)
        end

    end
  end
end

