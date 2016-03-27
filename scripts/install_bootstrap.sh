export VERSION=3.3.6

# Clean slate
rm bootstrap.tar.gz
rm -rf bootstrap-sass-`echo $VERSION`
# Cleanup source directories
rm -rf _sass/bootstrap
rm -rf assets/javascripts/bootstrap.min.js
rm -rf assets/fonts/bootstrap

curl -o bootstrap.tar.gz https://codeload.github.com/twbs/bootstrap-sass/tar.gz/v`echo $VERSION`
tar -xzvf bootstrap.tar.gz

# Copy assets to proper place
mv bootstrap-sass-`echo $VERSION`/assets/stylesheets _sass/bootstrap
mv bootstrap-sass-`echo $VERSION`/assets/fonts/bootstrap assts/fonts/bootstrap
mv bootstrap-sass-`echo $VERSION`/assets/javascripts/bootstrap.min.js assets/javascripts/bootstrap.min.js

# Cleanup
rm bootstrap.tar.gz
rm -rf bootstrap-sass-`echo $VERSION`
