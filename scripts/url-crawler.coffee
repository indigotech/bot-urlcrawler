# Description:
#   URL Crawler
#
# Dependencies:
#   swiftype
#   mongojs
#   request
#
# Configuration:
#   SLACK_TOKEN
#   MONGOLAB_URI
#   SWIFTYPE_TOKEN
#
# Commands:
#   url crawler - Taqtile URL Crawler - Use help-url to know more
#
# Author:
#   Taqtile

mongojs = require('mongojs')

configHelper = require('tq1-helpers').config_helper

# DEPS
async   = require('async')
childProcess = require('child_process')

#db
module_db = require('../url_crawler/db')
db = module_db mongojs

#filters
module_filter = require('../url_crawler/filter')
filters = module_filter db

#swiftype
module_swiftype = require('../url_crawler/swiftype')
swiftype = module_swiftype()

expression = /[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi
regex = new RegExp(expression)

createUrlArray = (text) ->
  console.log text
  if text
    urls = text.match regex
  return urls

module.exports = (robot) ->

  robot.hear expression, (msg) ->
    #TODO: check if there is a better way to avoid adding urls that were passed with commands
    if msg.message.text.indexOf("remove-url") > -1 or msg.message.text.indexOf("remove-url-filter") > -1 or msg.message.text.indexOf("remove-url-filter") > -1 or msg.message.text.indexOf("add-url-filter") > -1
      return
    urls = createUrlArray msg.message.text
    addedUrls = []
    async.each urls, (url, callback) ->
      filters.isFiltered url, (filtered) ->
        if filtered
          console.log url + " is filtered."
          callback()
        else
          console.log "No filter for " + url
          swiftype.addUrl url, msg.message.room, (err, res) ->
            if not err
              addedUrls.push url
            callback()
    , (err) ->
      if addedUrls.length > 0
        msg.send "Added the following URLs to the links system: " + addedUrls.toString()

  robot.respond /remove-url/, (msg) ->
    args = msg.message.text.split ' '
    if args[2]
      swiftype.removeUrl args[2], (err, res) ->
        if err
          msg.send "Could not remove url from the link system :("
        else
          msg.send "Removed url from the link system: " + args[2]
    else
      msg.send "I would have removed this if this was something ( ͡° ͜ʖ ͡°)"

  robot.respond /add-url-filter/, (msg) ->
    args = msg.message.text.split ' '
    if args[2]
      filters.addFilter args[2], (err, res) ->
        msg.send "Added filter for: " + args[2]
    else
      msg.send "Give me something to filter pl0x ( ͡° ͜ʖ ͡°)"

  robot.respond /help-url/, (msg) ->
    msg.send "I am SHIRLEY and I'm here to add all interesting URLs on our SUPER LINK SYSTEM that you can access by going to http://url.taqtile.io \n
    I accept the following commands: (you just need to mention me first so I know you are talking to me)\n
    remove-url <URL> - Will remove the url from the link system\n
    add-url-filter <URL> - Will not add URLs from the host of this URL anymore"
