# frozen_string_literal: true
require "json"
require "fileutils"

module Editor
  # Storage for revisions and dismissed proofreading findings, persisted as a
  # JSON file in tmp/ so that it survives server restarts.
  #
  # It lives outside of the autoloaded (reloadable) code and only holds plain
  # data so that it also survives development code reloads, which happen every
  # time a file in _posts/ is written.
  module Store
    @mutex = Monitor.new
    @_data = nil

    class << self
      def path=(path)
        synchronize do
          @_path = path
          @_data = nil
        end
      end

      def path
        @_path ||= Rails.root.join("tmp/editor/store-#{Rails.env}.json")
      end

      def synchronize(&)
        @mutex.synchronize(&)
      end

      # Records keyed by their String id.
      def collection(name)
        data["collections"][name.to_s] ||= {}
      end

      def next_id
        data["sequence"] += 1
      end

      def flags
        data["flags"]
      end

      # Call after mutating a collection, inside #synchronize.
      def persist!
        FileUtils.mkdir_p(File.dirname(path))
        temp = "#{path}.#{Process.pid}.tmp"
        File.write(temp, JSON.generate(data))
        File.rename(temp, path)
      end

      def reset!
        synchronize do
          @_data = empty
          FileUtils.rm_f(path)
        end
      end

      private

      def data
        @_data ||= File.exist?(path) ? JSON.parse(File.read(path)) : empty
      end

      def empty
        { "sequence" => 0, "collections" => {}, "flags" => {} }
      end
    end
  end
end
