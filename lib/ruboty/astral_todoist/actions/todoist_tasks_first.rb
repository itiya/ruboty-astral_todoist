require "ruboty/todoist_resource/items"
require "ruboty/astral_todoist/common/response"

module Ruboty
  module AstralTodoist
    module Actions
      class TodoistTasksFirst < Ruboty::Actions::Base

        def call
          message.reply(todoist_tasks(message))
        rescue => e
          message.reply(e.message)
        end

        private
        def todoist_tasks(message)
          project_name = message.match_data.named_captures["project_name"]
          specified_date = message.match_data.named_captures["date"]
          sort_type = message.match_data.named_captures["sort_type"]

          items = Ruboty::TodoistResource::Items.new(nil)
          begin
            first_content = items.filter_by_project(project_name).filter_by_due_date(specified_date).sort(sort_type).items.map{|item| item.content}.first
            if first_content == nil
              response(:all_tasks_completed)
            else
              first_content
            end
          rescue Ruboty::TodoistResource::ProjectNotFoundError
            response(:project_not_found)
          rescue Ruboty::TodoistResource::InvalidDateError
            response(:invalid_date)
          rescue Ruboty::TodoistResource::InvalidSortTypeError
            response(:invalid_sort_type)
          end
        end

        def response(event_symbol)
          Ruboty::AstralTodoist::Common::Response.instance.lines[event_symbol]
        end

      end
    end
  end
end
