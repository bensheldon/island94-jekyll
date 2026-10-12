# frozen_string_literal: true
# Only enable rules relevant to inline formatting issues in blog posts.
# Run via: bin/lint
rule "MD009" # Trailing spaces (2-space hard line breaks are still allowed)
rule "MD011" # Reversed link syntax: (text)[url] instead of [text](url)
rule "MD012" # Multiple consecutive blank lines
rule "MD022" # Headers should be surrounded by blank lines (no autofix)
rule "MD037" # Spaces inside emphasis markers: _ text_ or *text *
rule "MD038" # Spaces inside code span elements: ` text`
rule "MD039" # Spaces inside link text: [ text ](url)
rule "CUSTOM001" # Object replacement characters (U+FFFC), leftover from pasting
rule "CUSTOM002" # No-break spaces (U+00A0), leftover from pasting
rule "CUSTOM003" # Doubled spaces mid-line, outside of code blocks
