export VERSION=3.3.6

# Clean slate
rm bootstrap.tar.gz
rm -rf bootstrap-sass-`echo $VERSION`
# Cleanup source directories
rm -rf _sass/vendor/bootstrap
rm -rf assets/javascripts/vendor/bootstrap.min.js
rm -rf assets/fonts/bootstrap

curl -o bootstrap.tar.gz https://codeload.github.com/twbs/bootstrap-sass/tar.gz/v`echo $VERSION`
tar -xzvf bootstrap.tar.gz

# Copy assets to proper place
mv bootstrap-sass-`echo $VERSION`/assets/stylesheets _sass/vendor/bootstrap
mv bootstrap-sass-`echo $VERSION`/assets/fonts/bootstrap assets/fonts/bootstrap
mv bootstrap-sass-`echo $VERSION`/assets/javascripts/bootstrap.min.js assets/javascripts/vendor/bootstrap.min.js

# Cleanup
rm bootstrap.tar.gz
rm -rf bootstrap-sass-`echo $VERSION`
