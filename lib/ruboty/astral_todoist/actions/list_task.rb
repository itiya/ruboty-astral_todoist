module Ruboty
  module AstralTodoist
    module Actions
      class List_task < Ruboty::Actions::Base
        def call
          message.reply(list_task)
        rescue => e
          message.reply(e.message)
        end

        private
        def list_task
          # TODO: main logic
        end
      end
    end
  end
end
