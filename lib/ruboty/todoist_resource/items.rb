require 'time'
require "ruboty/todoist_resource/client"

module Ruboty
  module TodoistResource
    class ProjectNotFoundError < StandardError; end
    class InvalidDateError < StandardError; end
    class InvalidSortTypeError < StandardError; end

    class Items
      attr_reader :items

      def initialize(items = nil)
        if items == nil
          @client = Client.instance.client
          @items = @client.sync_items.collection.values
        else
          @items = items
        end
      end

      def filter_by_project(project_name)
        project = @client.sync_projects.collection.values.select {|item| item.name == project_name}.first
        if project == nil
          raise ProjectNotFoundError
        end

        items = @items.select do |item|
          # noinspection RubyResolve
          item.project_id == project.id
        end
        Items.new(items)
      end

      def filter_by_due_date(specified_date)
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
                raise InvalidDateError
            end

        items = @items.select do |v|
          # noinspection RubyResolve
          date_range == nil ? true : date_range.cover?(todoist_date_to_datetime(v.due_date_utc))
        end
        Items.new(items)
      end

      def sort(sort_type)
        if sort_type == "due_date"
          items = @items.sort do |a, b|
            # noinspection RubyResolve
            todoist_date_to_datetime(a.due_date_utc) <=> todoist_date_to_datetime(b.due_date_utc)
          end
          Items.new(items)
        elsif sort_type == "name"
          items = @items.sort do |a, b|
            # noinspection RubyResolve
            parse_content_and_link(a.content)[:content] <=> parse_content_and_link(b.content)[:content]
          end
          Items.new(items)
        else
          raise InvalidSortTypeError
        end
      end

      private

      def todoist_date_to_datetime(todoist_date)
        Time.rfc2822(todoist_date.clone.insert(3, ',')).getlocal
      end

      def parse_content_and_link(plane_content)
        match_data = /(?<url>.*)\s\((?<content>.*)\)/.match(plane_content)
        if match_data == nil
          {:link => nil, :content => plane_content}
        else
          {:link => match_data.named_captures["link"], :content => match_data.named_captures["content"]}
        end
      end

    end
  end
end