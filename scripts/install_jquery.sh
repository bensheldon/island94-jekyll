export VERSION=1.12.3

# Cleanup source directories
rm -rf assets/javascripts/vendor/jquery.min.js

# Download
curl -o jquery.min.js https://code.jquery.com/jquery-`echo $VERSION`.min.js

# Copy assets to proper place
mv jquery.min.js assets/javascripts/vendor/jquery.min.js
