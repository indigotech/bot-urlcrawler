URI = require('urijs')

module.exports = (db) ->

  isFiltered: (url, callback) ->
    db.getFilters (err, filters) ->
      uri = new URI url
      host = uri.host()
      if filters?.filters
        for filter in filters.filters
          if filter is host
            callback true
            return
        callback false
      callback false