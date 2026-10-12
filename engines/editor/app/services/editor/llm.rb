# frozen_string_literal: true
require "open3"

module Editor
  module Llm
    # Thin wrapper around the authenticated `claude` CLI, invoked non-interactively.
    class Cli
      class Error < StandardError; end

      # The cost of the most recent call, in US dollars.
      attr_reader :last_cost_usd

      DEFAULT_TIMEOUT = 600

      def initialize(
        binary: ENV.fetch("CLAUDE_BIN", "claude"),
        model: ENV.fetch("EDITOR_MODEL", "sonnet"),
        effort: ENV.fetch("EDITOR_EFFORT", "low"),
        timeout: DEFAULT_TIMEOUT
      )
        @binary = binary
        @model = model
        @effort = effort
        @timeout = timeout
      end

      # Runs a prompt whose result must match the JSON `schema`, and returns the
      # parsed result. `agents` defines subagents (see `claude --help`), and
      # `tools` lists the built-in tools the session may use.
      def structured(prompt, system:, schema:, agents: nil, tools: [])
        args = [
          @binary, "-p",
          "--output-format", "json",
          "--model", @model,
          "--effort", @effort,
          "--system-prompt", system,
          "--json-schema", schema.to_json,
          "--tools", tools.join(","),
          "--setting-sources", "",
          "--no-session-persistence"
        ]
        args += ["--allowedTools", tools.join(",")] if tools.any?
        args += ["--agents", agents.to_json] if agents

        out, err, status = run(args, prompt)
        raise Error, "claude CLI failed: #{err.presence || out.presence || 'no output'}" unless status&.success?

        envelope = JSON.parse(out)
        @last_cost_usd = envelope["total_cost_usd"]
        raise Error, "claude CLI error: #{envelope['result']}" if envelope["is_error"]

        envelope["structured_output"] || raise(Error, "claude CLI returned no structured output")
      rescue JSON::ParserError => e
        raise Error, "Could not parse CLI output: #{e.message}"
      end

      private

      # Runs the CLI in its own process group so that, if it doesn't finish in
      # time, it and anything it started can be killed.
      def run(args, stdin_data)
        Open3.popen3(*args, chdir: Rails.root.to_s, pgroup: true) do |stdin, stdout, stderr, wait_thread|
          out = Thread.new { stdout.read }
          err = Thread.new { stderr.read }
          stdin.write(stdin_data)
          stdin.close

          unless wait_thread.join(@timeout)
            kill(wait_thread.pid)
            raise Error, "claude CLI timed out after #{@timeout}s"
          end

          [out.value, err.value, wait_thread.value]
        end
      rescue Errno::ENOENT
        raise Error, "claude CLI not found (looked for #{@binary.inspect})"
      end

      def kill(pid)
        Process.kill("TERM", -pid)
        sleep 2
        Process.kill("KILL", -pid)
      rescue Errno::ESRCH
        # Already exited.
      end
    end
  end
end
