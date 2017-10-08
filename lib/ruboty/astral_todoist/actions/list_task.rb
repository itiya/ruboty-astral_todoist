require 'todoist'
require 'time'

module Ruboty
  module AstralTodoist
    module Actions
      class List_task < Ruboty::Actions::Base
        @@lines = {:project_not_found => "Project not found"}

        def call
          message.reply(list_task(message))
        rescue => e
          message.reply(e.message)
        end

        private
        def list_task(message)
          project_name = message.match_data.named_captures["project_name"]

          @client = Todoist::Client.create_client_by_token("#{ENV['TODOIST_TOKEN']}")
          project = @client.sync_projects.collection.select {|_, v| v.name == project_name}.values.first
          if project == nil
            return @@lines[:project_not_found]
          end

          @client.sync_items.collection.values.select do |v|
            # noinspection RubyResolve
            v.project_id == project.id
          end.sort do |a, b|
            # noinspection RubyResolve
            todoist_date_to_datetime(a.due_date_utc) <=> todoist_date_to_datetime(b.due_date_utc)
          end.map {|item| item.content}
        end

        def todoist_date_to_datetime(todoist_date)
          DateTime.rfc2822(todoist_date.clone.insert(3, ','))
        end
      end
    end
  end
end
