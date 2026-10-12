# frozen_string_literal: true
module Editor
  # A small pool of background threads that run editing passes. Shelling out to
  # the `claude` CLI takes a while, so passes run concurrently and outside of
  # any web request; the editor polls for their results.
  #
  # Like Editor::Store, this is not reloadable code. Each review is performed by
  # the (reloadable) Editor::ReviewRunner.
  module Reviewer
    CONCURRENCY = Integer(ENV.fetch("EDITOR_REVIEW_CONCURRENCY", 4))

    @queue = Thread::Queue.new
    @workers = []
    @mutex = Mutex.new

    class << self
      def enqueue(review_id)
        Store.synchronize { Store.active_reviews << review_id }
        start_workers
        @queue << review_id
      end

      private

      def start_workers
        @mutex.synchronize do
          @workers.select!(&:alive?)
          (CONCURRENCY - @workers.size).times do
            @workers << Thread.new { work }
          end
        end
      end

      def work
        while (review_id = @queue.pop)
          begin
            runner = Rails.application.executor.wrap { ReviewRunner.new(review_id) }
            runner.call
          rescue Exception => e # rubocop:disable Lint/RescueException
            Rails.logger.error("[Editor] Review #{review_id} crashed: #{e.class}: #{e.message}")
          ensure
            Store.synchronize { Store.active_reviews.delete(review_id) }
          end
        end
      end
    end
  end
end
