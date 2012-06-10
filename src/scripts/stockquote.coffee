# Stock quotes.
#
# quote me <ticker> - show current stock quote.

module.exports = (robot) ->

  robot.respond /quote( me)?( -(\d+\w+))? (.*)/i, (msg) ->
    ticker = msg.match[4]
    # "FB",26.145,"6/6/2012","11:39am",+0.276,26.09,26.64,25.52,31090006
    # $name,$current,$date,$time,$change,$open,$min,$max,$volume
    msg
      .http("http://download.finance.yahoo.com/d/quotes/csv?s=#{ticker}&f=sl1d1t1c1ohgv&e=.csv")
      .header("User-Agent: Crowdbot for Hubot (+https://github.com/github/hubot-scripts)")
      .get() (err, res, body) ->
        quote = parse_csv(body)
        fmtquote = format_quote msg, quote, ticker

parse_csv = (csv) ->
  csv = csv.replace(/"/g,'').replace(/\r|\n/g,'')

  parts = {}
  [ parts['name'],parts['current'],parts['date'],parts['time'],parts['change'],parts['open'],parts['min'],parts['max'],parts['volume']] = csv.split ","
  console.log(parts)
  return parts

format_quote = (msg, quote, symbol) ->
  if quote['current'] == 0.00
    msg.send "Unable to locate stock for #{symbol}"

  pct = (quote['change'] / ( quote['current'] - quote['change'])) * 100
  # "$name last $date $time: $current $change [$pct%] ($min - $max) " . "[Open $open] Vol $volume"
  fmtquote = "#{quote['name']} last #{quote['date']} #{quote['time']}: "
  fmtquote += "#{quote['current']} #{quote['change']} [#{pct.toFixed(3)}%] "
  fmtquote += "(#{quote['min']} - #{quote['max']}) [Open #{quote['open']}] "
  fmtquote += "Vol " + format_number(quote['volume'])
  msg.send fmtquote

format_number = (number) ->
  asstring = number + ''
  fmtnumber = ''
  for i in [asstring.length-1..0]
    if i % 3 == 0 && asstring.length - i > 0
      fmtnumber = ',' + fmtnumber
    fmtnumber = asstring[i] + fmtnumber
  return fmtnumber
