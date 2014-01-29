module Diffbot
  class APIClient

    # Diffbot Article API class
    class Article
      ALLOWED_PARAMS = [:fields, :timeout, :callback]

      # API version
      #
      # @return [String]
      attr_reader :version

      # HTTP method used when execute is called
      #
      # @return [String]
      attr_accessor :method

      # Query url used when execute is called
      #
      # @return [String]
      attr_accessor :query_url

      # HTML data used when POST execute is called
      #
      # @return [String]
      attr_accessor :data

      # Initializes a new Article object
      #
      # @param client [Diffbot::APIClient]
      # @param options [Hash]
      # @return [Diffbot::APIClient::Article]
      def initialize client, options = {}
        raise ArgumentError.new("client should be an instance of Diffbot::APIClient") unless client.is_a?(Diffbot::APIClient)

        @client = client
        @version = options.delete(:version) || 2
        @params = {}
      end

      # Add query params to future request
      #
      # @param params [Hash]
      # @return [Diffbot::Article]
      def query(params)
        @method = params[:method] if params.has_key?(:method)
        @query_url = params[:query_url] if params.has_key?(:query_url)

        @params = parse_params(params)

        self
      end

      # Return request URL
      #
      # @return [URI::HTTP]
      def url
        @client.endpoint + "v#{@version}/article"
      end

      # Return serialized request params
      #
      # @return [String]
      def query_params
        Faraday::Utils.build_query(@params)
      end

      # Makes GET request with params specified earlier
      #
      # @param query_url [String]
      # @return [String]
      def get query_url
        @client.get(self.url, @params.merge(:token => @client.token, :url => query_url)).body
      end

      # Makes POST request with params specified earlier
      #
      # @param query_url [String]
      # @return [String]
      def post query_url, data
        @client.post(self.url + "?#{Faraday::Utils.build_query(@params.merge(:token => @client.token, :url => query_url))}", data).body
      end

      # Executes request (GET or POST) with params specified earlier
      #
      # @return [String]
      def execute
        raise ArgumentError.new("HTTP method should be either :get or :post") unless [:get, :post].include?(@method)

        case @method
        when :get
          @client.send(@method, self.url, @params.merge(:token => @client.token, :url => @query_url)).body
        when :post
          @client.send(@method, self.url + "?#{Faraday::Utils.build_query(@params.merge(:token => @client.token, :url => @query_url))}", @data).body
        end
      end

      private

      def parse_params source
        target = {}

        ALLOWED_PARAMS.each do |param|
          next unless source.keys.include?(param)

          case param
          when :fields
            target[param] = source[param].is_a?(Array) ? source[param].join(",") : source[param]
          else
            target[param] = source[param]
          end
        end

        target
      end
    end

  end
end