URI = require('urijs')
swiftypeapi = require('swiftype')
request = require('request')

module.exports = () ->

  addUrl: (url, channel, callback) ->
    request url, (error, response, body) ->
      if error? or response.statusCode isnt 200
        console.log "Error on URL request: " + error
        callback(error)

      titleArray = body.match(/<title.*>\n?(.*?)<\/title>/)
      title = ""

      if titleArray? and titleArray[1]?
        title = titleArray[1]
      else
        title = url

      descriptionArray = body.match('<meta name=\"description\" content=\"(.*)\"')

      if descriptionArray? and descriptionArray[1]?
        description = descriptionArray[1]
        description = description.split("\"")[0]
      else
        description = ""
      tagsArray = body.match('<meta name=\"keywords\" content=\"(.*)\"')
      if tagsArray? and tagsArray[1]?
        tags = tagsArray[1].replace(/,/g," ")
        tags = tags.split("\"")[0]
        tags = tags.split("/")[0]
      if not tags?
        tags = ""
      tags = tags + " " + channel
      console.log "going to send this to swiftype: " + url
      console.log title
      console.log description
      console.log tags
      console.log process.env.SWIFTYPE_TOKEN
      swiftype = new swiftypeapi(apiKey: process.env.SWIFTYPE_TOKEN)
      swiftype.documents.create {
        engine: 'knowledgebase'
        documentType: 'links'
        document:
          external_id: url
          fields: [
            {
              name: 'title'
              value: title
              type: 'string'
            }
            {
              name: 'description'
              value: description
              type: 'string'
            }
            {
              name: 'keywords'
              value: tags
              type: 'string'
            }
            {
              name: 'url'
              value: url
              type: 'string'
            }
          ]
      }, (err, res) ->
        if err?
          console.log "ERROR sending to swiftype: " + err
          callback err
        else
          callback res
