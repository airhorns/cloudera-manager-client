module ClouderaManager
  module Middleware
    class JSONParser < Her::Middleware::ParseJSON
      def parse(body)
        json = parse_json(body)

        # ClouderaManager's API listings all have a key :items pointing to an array
        # of items. http://cloudera.github.io/cm_api/apidocs/v10/ns0_apiListBase.html
        if json.key?(:items)
          json = json[:items]
        end
        errors = json.delete(:errors) || {}
        metadata = json.delete(:metadata) || {}
        {
          :data => json,
          :errors => errors,
          :metadata => metadata
        }
      end
    end
  end
end
