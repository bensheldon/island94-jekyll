# frozen_string_literal: true
class RedirectToMetaRefresh
  def initialize(app)
    @app = app
  end

  def call(env)
    # The local-only editor is a regular web app and uses real redirects.
    return @app.call(env) if env["PATH_INFO"].start_with?("/editor")

    status, headers, body = @app.call(env)

    if (300..399).cover?(status) && headers['Location']
      [200, {
        'Content-Type' => 'text/html',
      }, [build_meta_refresh(headers['Location'])]]
    else
      [status, headers, body]
    end
  end

  private

  def build_meta_refresh(url)
    <<~HTML
      <!DOCTYPE html>
      <html>
        <meta charset="utf-8">
        <title>Redirecting...</title>
        <link rel="canonical" href="#{url}">
        <head>
          <meta http-equiv="refresh" content="0; url=#{url}">
          <meta name="robots" content="noindex">
        </head>
        <body>
          Redirecting to <a href="#{url}">#{url}</a>...
        </body>
      </html>
    HTML
  end
end
