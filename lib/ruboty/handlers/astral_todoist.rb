require "ruboty/astral_todoist/actions/todoist_tasks"
require "ruboty/astral_todoist/actions/todoist_tasks_first"
require "ruboty/astral_todoist/actions/todoist_tasks_complete_first"

module Ruboty
  module Handlers
    # Todoist plugin
    class AstralTodoist < Base
      on /todoist tasks list\s+(?<date>.*)\s+(?<project_name>.*)/, name: 'todoist_tasks', description: 'list tasks'
      on /todoist tasks first\s+(?<date>.*)\s+(?<project_name>.*)/, name: 'todoist_tasks_first', description: 'take first task'
      on /todoist tasks complete_first\s+(?<date>.*)\s+(?<project_name>.*)/, name: 'todoist_tasks_complete_first', description: 'complete first task'
      env :TODOIST_TOKEN, "Todoist account API token"

      def todoist_tasks(message)
        Ruboty::AstralTodoist::Actions::TodoistTasks.new(message).call
      end

      def todoist_tasks_first(message)
        Ruboty::AstralTodoist::Actions::TodoistTasksFirst.new(message).call
      end

      def todoist_tasks_complete_first(message)
        Ruboty::AstralTodoist::Actions::TodoistTasksCompleteFirst.new(message).call
      end

    end
  end
end
