(function() {
  // Adapted from https://aaronluna.dev/blog/add-search-to-static-site-lunrjs-hugo-vanillajs/
  const MAX_SUMMARY_LENGTH = 250;
  const SENTENCE_BOUNDARY_REGEX = /\b\.\s/gm;
  const WORD_REGEX = /\b(\w*)[\W|\s|\b]?/gm;

  function createSearchResultBlurb(query, pageContent) {
    const searchQueryRegex = new RegExp(createQueryStringRegex(query), "gmi");
    const searchQueryHits = Array.from(
      pageContent.matchAll(searchQueryRegex),
      (m) => m.index
    );
    const sentenceBoundaries = Array.from(
      pageContent.matchAll(SENTENCE_BOUNDARY_REGEX),
      (m) => m.index
    );

    let searchResultText = "";
    let lastEndOfSentence = 0;
    for (const hitLocation of searchQueryHits) {
      if (hitLocation > lastEndOfSentence) {
        for (let i = 0; i < sentenceBoundaries.length; i++) {
          if (sentenceBoundaries[i] > hitLocation) {
            const startOfSentence = i > 0 ? sentenceBoundaries[i - 1] + 1 : 0;
            const endOfSentence = sentenceBoundaries[i];
            lastEndOfSentence = endOfSentence;
            const parsedSentence = pageContent.slice(startOfSentence, endOfSentence).trim();
            searchResultText += `${parsedSentence} ... `;
            break;
          }
        }
      }
      const searchResultWords = tokenize(searchResultText);
      const pageBreakers = searchResultWords.filter((word) => word.length > 50);
      if (pageBreakers.length > 0) {
        searchResultText = fixPageBreakers(searchResultText, pageBreakers);
      }
      if (searchResultWords.length >= MAX_SUMMARY_LENGTH) break;
    }
    return ellipsize(searchResultText, MAX_SUMMARY_LENGTH).replace(
      searchQueryRegex,
      "<mark>$&</mark>"
    );
  }

  function createQueryStringRegex(query) {
    const searchTerms = query.split(" ");
    if (searchTerms.length === 1) {
      return query;
    }
    query = "";
    for (const term of searchTerms) {
      query += `${term}|`;
    }
    query = query.slice(0, -1);
    return `(${query})`;
  }

  function tokenize(input) {
    const wordMatches = Array.from(input.matchAll(WORD_REGEX), (m) => m);
    return wordMatches.map((m) => ({
      word: m[0],
      start: m.index,
      end: m.index + m[0].length,
      length: m[0].length,
    }));
  }

  function fixPageBreakers(input, largeWords) {
    largeWords.forEach((word) => {
      const chunked = chunkify(word.word, 20);
      input = input.replace(word.word, chunked);
    });
    return input;
  }

  function chunkify(input, chunkSize) {
    let output = "";
    let totalChunks = (input.length / chunkSize) | 0;
    let lastChunkIsUneven = input.length % chunkSize > 0;
    if (lastChunkIsUneven) {
      totalChunks += 1;
    }
    for (let i = 0; i < totalChunks; i++) {
      let start = i * chunkSize;
      let end = start + chunkSize;
      if (lastChunkIsUneven && i === totalChunks - 1) {
        end = input.length;
      }
      output += input.slice(start, end) + " ";
    }
    return output;
  }

  function ellipsize(input, maxLength) {
    const words = tokenize(input);
    if (words.length <= maxLength) {
      return input;
    }
    return input.slice(0, words[maxLength].end) + "...";
  }

  function formatSearchResults(searchQuery, searchResults, searchIndex) {
    if (searchResults.length) {
      let output = "";

      for (const result of searchResults) {
        const item = searchIndex[result.ref];
        output += '<a href="' + item.url + '"><h2>' + item.title + '</h2></a>';
        output += '<p class="post-meta text-muted">' + item.published + '</p>';

        let blurb = createSearchResultBlurb(searchQuery, item.content);
        if (blurb.trim().length == 0) {
          blurb = item.content.substring(0, MAX_SUMMARY_LENGTH) + '...';
        }
        output += '<p>' + blurb + '</p>';
      }

      return output;
    } else {
      return '<p>No results found</p>';
    }
  }

  const urlParams = new URLSearchParams(window.location.search);
  const searchQuery = urlParams.get("q");
  const resultsEl = document.getElementById('search-results');

  if (!searchQuery) {
    resultsEl.innerHTML = '<p>No search term</p>';
    return
  }
  document.getElementById('search-box').setAttribute("value", searchQuery);

  fetch('/search.json').then(function (response) {
    return response.json();
  }).then(function (searchIndex) {
    const idx = lunr(function() {
      this.field('id');
      this.field('title', { boost: 10 });
      this.field('tags', { boost: 10 });
      this.field('content');

      for (const key in searchIndex) {
        const item = searchIndex[key];

        this.add({
          'id': key,
          'title': item.title,
          'published': item.published,
          'tags': item.tags,
          'content': item.content
        });
      }
    });

    const searchResults = idx.search(searchQuery);
    resultsEl.innerHTML = formatSearchResults(searchQuery, searchResults, searchIndex);
  });
})();
