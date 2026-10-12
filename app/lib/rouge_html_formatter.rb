# frozen_string_literal: true

# Kramdown defaults to the deprecated Rouge::Formatters::HTMLLegacy, which
# wraps rendered token spans in <div class="highlight"><pre class="highlight">
# <code>...markup that app/assets/stylesheets/application.css.scss and the
# rouge theme partials style via ".highlighter-rouge > .highlight". This is
# that same wrapping without the deprecation warning.
class RougeHtmlFormatter < Rouge::Formatters::HTML
  def stream(tokens, &)
    yield %(<div class="highlight"><pre class="highlight"><code>)
    super
    yield "</code></pre></div>"
  end
end
