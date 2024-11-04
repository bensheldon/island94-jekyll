module RouteHelper
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
