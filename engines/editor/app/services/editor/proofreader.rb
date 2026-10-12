# frozen_string_literal: true
module Editor
  # Proofreads a document with a single `claude` session: a lead editor runs a
  # subagent for each check in parallel, then merges their findings, combining
  # overlapping ones and resolving conflicting suggestions.
  class Proofreader
    FINDINGS_SCHEMA = {
      type: "object",
      properties: {
        findings: {
          type: "array",
          items: {
            type: "object",
            properties: {
              quote: { type: "string", description: "The exact text from the post that has the problem" },
              comment: { type: "string", description: "A short explanation of the problem" },
              suggestion: { type: %w[string null], description: "The corrected replacement for the quote, or null" },
              severity: { type: "string", enum: %w[low medium high] },
              checks: { type: "array", items: { type: "string" }, description: "The names of the checks that found it" },
            },
            required: %w[quote comment checks],
          },
        },
      },
      required: ["findings"],
    }.freeze

    def cost_usd = @llm.last_cost_usd

    def initialize(document, passes, llm: Llm::Cli.new)
      @document = document
      @passes = passes
      @llm = llm
      @text = document.text
    end

    # The slow part: asks the model. Safe to call outside of the Rails executor.
    def fetch_findings
      return [] if @text.strip.blank?

      with_post_file do |path|
        result = @llm.structured(
          "Proofread the blog post in the file #{path} by running these proofreader subagents: " \
          "#{@passes.map(&:slug).join(', ')}. Then return the combined findings.",
          system: Personas::LEAD,
          schema: FINDINGS_SCHEMA,
          agents: agents,
          tools: %w[Agent Read]
        )
        Array(result["findings"])
      end
    end

    # Returns the number of findings created.
    def create_highlights(findings)
      existing = @document.highlights
      findings.count do |finding|
        quote = locate(finding["quote"].to_s.strip)
        comment = finding["comment"].to_s.strip
        passes = Array(finding["checks"]).filter_map { |slug| @passes.find { |pass| pass.slug == slug.to_s } }.presence || @passes.first(1)
        # Only anchor findings we can actually locate in the text.
        next false if quote.blank? || comment.blank? || @text.exclude?(quote)
        next false if existing.any? { |highlight| highlight.quote == quote && highlight.checks.intersect?(passes.map(&:slug)) }

        existing << Highlight.create!(
          document_id: @document.id,
          quote: quote,
          original_quote: quote,
          color: passes.first.color,
          category: passes.first.slug,
          checks: passes.map(&:slug),
          pass_name: passes.map(&:name).join(" · "),
          severity: Highlight::SEVERITIES.include?(finding["severity"]) ? finding["severity"] : "medium",
          comment: comment,
          suggestion: Markdown.straighten_quotes(finding["suggestion"].to_s.strip).presence
        )
      end
    end

    private

    # A subagent for each check.
    def agents
      @passes.to_h do |pass|
        [pass.slug, {
          description: "Proofreads a blog post for: #{pass.name}",
          prompt: <<~PROMPT,
            #{Personas::PROOFREADER}
            You are checking the post for ONE kind of problem only:

            #{pass.name.upcase}
            #{pass.prompt}

            Read the post from the file path you're given. Unless your check is
            about code, do not flag code. Reply with ONLY a JSON array, one
            object per problem, each with: "quote" (copied exactly, character for
            character, from the post, and as short as possible while still
            unambiguous), "comment" (a short explanation), "suggestion" (the
            corrected replacement for the quote, or null), and "severity" ("low",
            "medium", or "high"). If there are none, reply with [].
          PROMPT
          tools: ["Read"],
        }]
      end
    end

    # The post's text, as displayed in the editor, in a temporary file for the
    # subagents to read.
    def with_post_file
      directory = Rails.root.join("tmp/editor/reviews")
      FileUtils.mkdir_p(directory)
      path = directory.join("#{@document.id}-#{SecureRandom.hex(4)}.txt")
      File.write(path, @text)
      yield path
    ensure
      FileUtils.rm_f(path) if path
    end

    # The model sometimes changes the quotes and apostrophes in what it quotes,
    # so fall back to matching any quote character.
    def locate(quote)
      return quote if @text.include?(quote)

      pattern = Regexp.new(Regexp.escape(Markdown.straighten_quotes(quote)).gsub("'", "['‘’]").gsub('"', '["“”]'))
      @text[pattern] || quote
    end
  end
end
