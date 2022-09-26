---
---
{% include_relative vendor/lunr.min.js %}

(function() {
  const RESULT_SIZE = 500

  function formatSearchResults(results, store) {
    if (results.length) {
      let output = "";

      for (const result of results) {
        const item = store[result.ref];
        output += '<a href="' + item.url + '"><h3>' + item.title + '</h3></a>';
        output += '<p class="post-meta text-muted">' + item.published + '</p>';
        output += '<p>' + item.content.substring(0, RESULT_SIZE) + '...</p>';
      }

      return output;
    } else {
      return '<p>No results found</p>';
    }
  }

  const urlParams = new URLSearchParams(window.location.search);
  const searchTerm = urlParams.get("q");
  const resultsEl = document.getElementById('search-results');

  if (!searchTerm) {
    resultsEl.innerHTML = '<p>No search term</p>';
    return
  }
  document.getElementById('search-box').setAttribute("value", searchTerm);


  fetch('/search.json').then(function (response) {
    return response.json();
  }).then(function (items) {
    const idx = lunr(function() {
      this.field('id');
      this.field('title', { boost: 10 });
      this.field('tags', { boost: 10 });
      this.field('content');

      for (const key in items) {
        const item = items[key];

        this.add({
          'id': key,
          'title': item.title,
          'published': item.published,
          'tags': item.tags,
          'content': item.content
        });
      }
    });

    const searchResults = idx.search(searchTerm);
    resultsEl.innerHTML = formatSearchResults(searchResults, items);
  });
})();
