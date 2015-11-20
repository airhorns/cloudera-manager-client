module ClouderaManager
  module Middleware
    class URLPrefix
      def initialize(app, prefix)
        @app = app
        @prefix = prefix
      end

      def call(request_env)
        uri = request_env['url'].dup
        uri.path = @prefix + uri.path
        request_env['url'] = uri
        @app.call(request_env)
      end
    end
  end
end
