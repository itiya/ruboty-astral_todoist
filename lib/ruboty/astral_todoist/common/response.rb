require 'singleton'

module Ruboty
  module AstralTodoist
    module Common
      class Response
        attr_reader :lines
        include Singleton

        def initialize
          @lines = {
              :project_not_found => "Project not found",
              :invalid_date => "Invalid date",
              :invalid_sort_type => "Invalid sort type",
              :all_tasks_completed => "All tasks completed",
              :complete_task => "Complete <task_name>"
          }
        end

      end
    end
  end
end
