require 'singleton'
require 'todoist'

module Ruboty
  module TodoistResource
    class Client
      attr_reader :client

      include Singleton
      def initialize
        @client = Todoist::Client.create_client_by_token("#{ENV['TODOIST_TOKEN']}")
      end
    end
  end
end
