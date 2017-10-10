module Ruboty
  module Todoist
    class ProjectNotFoundError < StandardError; end
    class InvalidDateError < StandardError; end

    class Items
      attr_reader :items

      @@client = Todoist::Client.create_client_by_token("#{ENV['TODOIST_TOKEN']}")

      def initialize(items = nil)
        if items == nil
          @items = @@client.sync_items.collection.values
        else
          @items = items
        end
      end

      def filter_by_project(project_name)
        project = @@client.sync_projects.collection.values.select {|item| item.name == project_name}.first
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

      def sort_by_due_date
        items = @items.sort do |a, b|
          # noinspection RubyResolve
          todoist_date_to_datetime(a.due_date_utc) <=> todoist_date_to_datetime(b.due_date_utc)
        end
        Items.new(items)
      end

      private

      def todoist_date_to_datetime(todoist_date)
        Time.rfc2822(todoist_date.clone.insert(3, ',')).getlocal
      end

    end
  end
end