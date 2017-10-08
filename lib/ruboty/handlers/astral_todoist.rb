require "ruboty/astral_todoist/actions/list_task"

module Ruboty
  module Handlers
    # Todoist plugin
    class AstralTodoist < Base
      on /list task\s+(?<project_name>.*)/, name: 'list_task', description: 'list task'
      env :TODOIST_TOKEN, "Todoist account API token"

      def list_task(message)
        Ruboty::AstralTodoist::Actions::List_task.new(message).call
      end

    end
  end
end
