require 'bitflyer'
require 'pry-byebug'

sfd=1.1
losscut=1.09
buyrate=1.095
sellrate=1.102
order_size=0.001

private_client = Bitflyer.http_private_client('YOUR_API_KEY', 'YOUR_API_SECRET')
public_client = Bitflyer.http_public_client

btc_jpy = public_client.ticker('BTC_JPY')['ltp']
fx_btc_jpy = public_client.ticker('FX_BTC_JPY')['ltp']
est = fx_btc_jpy / btc_jpy

position = private_client.positions[0]

puts '加納キャノン!!!'
puts "今の乖離率は#{(est - 1) * 100}%だしん"

if position && position['side'] == 'BUY'
  if est > sellrate || est < losscut
    puts '乖離率が閾値を超過したので売るしん' if est > (sfd + 1.003)
    puts '乖離率が減少したので売るしん' if est < losscut
    private_client.send_child_order(product_code: 'FX_BTC_JPY', child_order_type: 'MARKET', side: "SELL", size: position['size'])
    sleep 60
  end
  return
end

if buyrate < est && est < sfd
  puts '乖離率が閾値に近づいたので買い注文するしん'
  private_client.send_child_order(product_code: 'FX_BTC_JPY', child_order_type: 'MARKET', side: "BUY", size: order_size)
end

puts ''