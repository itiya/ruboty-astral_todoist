require 'todoist'
require 'time'

module Ruboty
  module AstralTodoist
    module Actions
      class TodoistTasks < Ruboty::Actions::Base
        @@lines = {
            :project_not_found => "Project not found",
            :invalid_date => "Invalid date"
        }
        @@client = Todoist::Client.create_client_by_token("#{ENV['TODOIST_TOKEN']}")

        def call
          message.reply(todoist_tasks(message))
        rescue => e
          message.reply(e.message)
        end

        private
        def todoist_tasks(message)
          project_name = message.match_data.named_captures["project_name"]
          specified_date = message.match_data.named_captures["date"]

          items = filter_by_project(@@client.sync_items.collection.values, project_name)
          items = filter_by_due_date(items, specified_date)
          sort_by_due_date(items).map {|item| item.content}
        end

        def filter_by_project(items, project_name)
          project = @@client.sync_projects.collection.select {|_, v| v.name == project_name}.values.first
          if project == nil
            raise @@lines[:project_not_found]
          end

          items.select do |item|
            # noinspection RubyResolve
            item.project_id == project.id
          end
        end

        def filter_by_due_date(items, specified_date)
          date_range =
              case specified_date
                when "all" then
                  nil
                when "today" then
                  now = Time.now
                  Time.local(now.year, now.month, now.day)..Time.local(now.year, now.month, now.day+1)
                when "7days" then
                  now = Time.now
                  Time.local(now.year, now.month, now.day)..Time.local(now.year, now.month, now.day+8)
                else
                  raise @@lines[:invalid_date]
              end

          items.select do |v|
            # noinspection RubyResolve
            date_range == nil ? true : date_range.cover?(todoist_date_to_datetime(v.due_date_utc))
          end
        end

        def sort_by_due_date(items)
          items.sort do |a, b|
            # noinspection RubyResolve
            todoist_date_to_datetime(a.due_date_utc) <=> todoist_date_to_datetime(b.due_date_utc)
          end
        end

        def todoist_date_to_datetime(todoist_date)
          Time.rfc2822(todoist_date.clone.insert(3, ',')).getlocal
        end

      end
    end
  end
end
