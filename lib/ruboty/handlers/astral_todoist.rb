require "ruboty/astral_todoist/actions/todoist_tasks"

module Ruboty
  module Handlers
    # Todoist plugin
    class AstralTodoist < Base
      on /todoist tasks\s+(?<project_name>.*)/, name: 'todoist_tasks', description: 'list tasks'
      env :TODOIST_TOKEN, "Todoist account API token"

      def todoist_tasks(message)
        Ruboty::AstralTodoist::Actions::TodoistTasks.new(message).call
      end

    end
  end
end
