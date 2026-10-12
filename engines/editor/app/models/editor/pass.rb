# frozen_string_literal: true
module Editor
  # A reusable review pass: one focused prompt that asks the model to find a
  # single kind of problem in the piece.
  class Pass < Record
    attribute :slug, :string
    attribute :name, :string
    attribute :color, :string, default: "yellow"
    attribute :prompt, :string
    attribute :position, :integer, default: 0
    attribute :active, :boolean, default: true

    validates :name, :slug, :prompt, presence: true
    validates :color, inclusion: { in: Highlight::COLORS }

    # The default checks: a proofreader, not a style critic. Each one looks for
    # a single kind of mechanical problem.
    DEFAULTS = [
      {
        slug: "spelling",
        name: "Spelling & typos",
        color: "pink",
        prompt: <<~PROMPT,
          Find misspelled words, typos, doubled words ("the the"), missing words,
          wrong words that are real words (e.g. "form" for "from"), and garbled
          leftovers from editing (half-deleted phrases, words in the wrong order).
          Ignore code, names, and deliberate slang.
        PROMPT
      },
      {
        slug: "grammar",
        name: "Grammar",
        color: "orange",
        prompt: <<~PROMPT,
          Find grammatical errors: subject-verb agreement, pronoun-antecedent
          agreement, wrong articles (a/an), wrong word forms, and commonly confused
          words (its/it's, their/there/they're, affect/effect, then/than,
          lose/loose, who's/whose, fewer/less).
        PROMPT
      },
      {
        slug: "punctuation",
        name: "Punctuation & formatting",
        color: "yellow",
        prompt: <<~PROMPT,
          Find punctuation and formatting mistakes: missing or extra commas
          (especially comma splices and missing commas after introductory
          clauses), misused apostrophes, unbalanced quotes or parentheses, missing
          end punctuation, double spaces, inconsistent capitalization (including
          in headings and product names), and inconsistent formatting of list
          items.
        PROMPT
      },
      {
        slug: "consistency",
        name: "Tense & voice consistency",
        color: "blue",
        prompt: <<~PROMPT,
          Find unintended shifts within a passage: switching between past and
          present tense when describing the same events, mixing active and
          passive voice in a way that obscures who did what, switching point of
          view (I/we/you/one), and inconsistent spelling or naming of the same
          thing. Only flag a shift that reads as a mistake, not a deliberate change.
        PROMPT
      },
      {
        slug: "construction",
        name: "Sentence construction",
        color: "purple",
        prompt: <<~PROMPT,
          Find sentences that are broken in construction: run-on sentences,
          unintended fragments, dangling or misplaced modifiers, unclear pronoun
          references, faulty parallelism in lists or pairs, and sentences whose
          beginning and end don't fit together grammatically.
        PROMPT
      },
      {
        slug: "code",
        name: "Code",
        color: "green",
        prompt: <<~PROMPT,
          Review the inline code and code blocks, to the extent you can tell from
          the post: syntax errors; misspelled or nonexistent methods, classes,
          options, or commands; code that wouldn't run or wouldn't do what the
          surrounding prose says it does; example output (e.g. "# =>" comments)
          that doesn't match the code; and names that are inconsistent between
          snippets or between the code and the prose. Only flag what you're
          confident is wrong, and say what you're assuming. Quote a single line
          of code at most.
        PROMPT
      },
    ].freeze

    # Bump when DEFAULTS change to replace the passes stored in a workspace,
    # along with findings and reviews from passes that no longer exist.
    DEFAULTS_VERSION = 4

    def self.all
      seed_defaults!
      super.sort_by { |pass| [pass.position, pass.id] }
    end

    def active? = active

    def self.active
      all.select(&:active?)
    end

    def self.seed_defaults!
      Store.synchronize do
        next if Store.flags["passes_version"] == DEFAULTS_VERSION

        Store.collection(name).clear
        retired = ->(value, current) { value.present? && current.exclude?(value) }
        Highlight.all.each { |highlight| highlight.destroy if retired.call(highlight.category, DEFAULTS.pluck(:slug)) }
        Review.all.each { |review| review.destroy if retired.call(review.pass_name, DEFAULTS.pluck(:name)) }
        Store.flags["passes_version"] = DEFAULTS_VERSION
        DEFAULTS.each_with_index { |attrs, index| create!(**attrs, position: index) }
      end
    end
  end
end
