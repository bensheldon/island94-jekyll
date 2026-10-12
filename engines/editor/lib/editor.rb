# frozen_string_literal: true
require_relative "editor/store"
require_relative "editor/engine"

# A local-only writing tool for drafting and workshopping blog posts.
# Only loaded in development and test (see config/application.rb); it is never
# part of the published static site.
module Editor
end
