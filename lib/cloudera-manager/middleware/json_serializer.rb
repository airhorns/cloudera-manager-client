module ClouderaManager
  module Middleware
    class JSONSerializer
      def initialize(app)
        @app = app
      end

      def call(request_env)
        body = request_env[:body]
        if !body.nil? && !body.respond_to?(:to_str)
          if body.is_a?(Array)
            body = { items: body }
          end
          request_env[:body] = MultiJson.dump(body)
          request_env[:request_headers]['Content-type'] = "application/json"
        end

        @app.call(request_env)
      end
    end
  end
end
