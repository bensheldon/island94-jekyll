# frozen_string_literal: true
module Editor
  module ApplicationHelper
    def color_swatch(color, **options)
      tag.span(class: ["color-swatch", "hl-#{color}", options.delete(:class)], **options)
    end

    # Renders the change from `original` to `suggestion` inline, word by word.
    def suggestion_diff(original, suggestion)
      safe_join(TextDiff.new(original, suggestion).changes.map do |type, text|
        case type
        when :delete then tag.del(text, class: "diff-delete")
        when :insert then tag.ins(text, class: "diff-insert")
        else text
        end
      end)
    end

    def severity_badge_class(severity)
      case severity
      when "high" then "text-bg-danger"
      when "medium" then "text-bg-warning"
      else "text-bg-secondary"
      end
    end
  end
end
