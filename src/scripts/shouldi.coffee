# Randomly choose activity from list
#
# should I a, b, or c?

module.exports = (robot) ->

  robot.respond /should i (.*)/i, (msg) ->
    choosefrom = msg.match[1]
    list = parse_list(choosefrom)
    msg.send list[randomInt(0,list.length - 1)]

parse_list = (choosefrom) ->
  parts = []
  choosefrom = choosefrom.replace(/\?+$/,'')
  choosefrom = choosefrom.replace(/\s+or\s+/,',')
  choosefrom = choosefrom.replace(/\s+,/g,',')
  choosefrom = choosefrom.replace(/,\s+/g,',')
  choosefrom = choosefrom.replace(/,+/g,',')
  parts = choosefrom.split /,/
  return parts

randomInt = (lower, upper=0) ->
  start = Math.random()
  if not lower?
    [lower, upper] = [0, lower]
  if lower > upper
    [lower, upper] = [upper, lower]
  return Math.floor(start * (upper - lower + 1) + lower)
