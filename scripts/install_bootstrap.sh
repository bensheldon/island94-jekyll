export VERSION=5.3.0

# Clean slate
rm bootstrap.tar.gz
rm bootstrap.zip
rm -rf bootstrap-${VERSION}

# Cleanup source directories
rm -rf _sass/vendor/bootstrap
rm -rf assets/javascripts/vendor/bootstrap.bundle.min.js
rm -rf assets/fonts/bootstrap

curl -L https://github.com/twbs/bootstrap/archive/refs/tags/v${VERSION}.zip -o bootstrap.zip
unzip bootstrap.zip

# Copy assets to proper place
mv bootstrap-${VERSION}/scss _sass/vendor/bootstrap
mv bootstrap-${VERSION}/dist/js/bootstrap.bundle.min.js assets/javascripts/vendor/bootstrap.bundle.min.js
sed -i '' '/^\/\/# sourceMappingURL=/d' assets/javascripts/vendor/bootstrap.bundle.min.js

# Cleanup
rm bootstrap.zip
rm -rf bootstrap-${VERSION}
