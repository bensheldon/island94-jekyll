# frozen_string_literal: true
module Editor
  # A word-level diff of two short strings, for showing what a suggestion changes.
  class TextDiff
    TOKEN = /\w+|\s+|[^\w\s]/

    def initialize(original, changed)
      @original = original.to_s.scan(TOKEN)
      @changed = changed.to_s.scan(TOKEN)
    end

    # An array of [type, text] where type is :equal, :delete, or :insert.
    # Adjacent changes of the same type are merged.
    def changes
      merge(walk)
    end

    private

    # Longest common subsequence table, then a walk from the start.
    def walk
      lengths = Array.new(@original.size + 1) { Array.new(@changed.size + 1, 0) }
      (@original.size - 1).downto(0) do |i|
        (@changed.size - 1).downto(0) do |j|
          lengths[i][j] = if @original[i] == @changed[j]
                            lengths[i + 1][j + 1] + 1
                          else
                            [lengths[i + 1][j], lengths[i][j + 1]].max
                          end
        end
      end

      changes = []
      i = j = 0
      while i < @original.size || j < @changed.size
        if i < @original.size && j < @changed.size && @original[i] == @changed[j]
          changes << [:equal, @original[i]]
          i += 1
          j += 1
        elsif i < @original.size && (j >= @changed.size || lengths[i + 1][j] >= lengths[i][j + 1])
          changes << [:delete, @original[i]]
          i += 1
        else
          changes << [:insert, @changed[j]]
          j += 1
        end
      end
      changes
    end

    # Merges runs of the same type.
    def merge(changes)
      changes.each_with_object([]) do |(type, text), merged|
        if merged.any? && merged.last[0] == type
          merged.last[1] += text
        else
          merged << [type, +text]
        end
      end
    end
  end
end
