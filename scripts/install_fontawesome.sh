export VERSION=4.6.2

# Clean slate
rm fontawesome.zip
rm -rf font-awesome-`echo $VERSION`
# Cleanup source directories
rm -rf _sass/vendor/fontawesome
rm -rf assets/fonts/fontawesome

curl -o fontawesome.zip http://fontawesome.io/assets/font-awesome-`echo $VERSION`.zip
unzip fontawesome.zip

# Copy assets to proper place
mv font-awesome-`echo $VERSION`/scss _sass/vendor/fontawesome
mv font-awesome-`echo $VERSION`/fonts assets/fonts/fontawesome

# Cleanup
rm fontawesome.zip
rm -rf font-awesome-`echo $VERSION`
