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
  parts = csv.split ","

format_quote = (msg, quote, symbol) ->
  if quote[1] == 0.00
    msg.send "Unable to locate stock for #{symbol}"

  pct = (quote[4] / ( quote[1] - quote[4])) * 100
  # "$name last $date $time: $current $change [$pct%] ($min - $max) " . "[Open $open] Vol $volume"
  fmtquote = "#{quote[0]} last #{quote[2]} #{quote[3]}: #{quote[1]} #{quote[4]} [#{pct.toFixed(3)}%] (#{quote[6]} - #{quote[7]}) [Open #{quote[5]}] Vol #{quote[8]}"
  msg.send fmtquote.replace(/"/g,'')
