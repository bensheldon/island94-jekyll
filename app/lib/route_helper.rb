module RouteHelper
  def strip_leading_slash(string)
    string.sub(%r{\A/}, "")
  end

  def strip_trailing_slash(string)
    string.sub(%r{/\z}, "")
  end

  def strip_outer_slashes(string)
    strip_leading_slash(strip_trailing_slash(string))
  end

  def self.method_missing(method_name, *, **kwargs, &)
    return super unless Rails.application.routes.url_helpers.respond_to?(method_name)

    default_url_options = Rails.configuration.default_url_options.clone
    url_options = default_url_options.merge(kwargs)
    Rails.application.routes.url_helpers.send(method_name, *, **url_options, &)
  end

  def self.respond_to_missing?(method_name, *)
    Rails.application.routes.url_helpers.respond_to?(method_name, *) || super
  end
end
