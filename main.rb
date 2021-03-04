require 'net/http'
require 'uri'
require 'rexml/document'

VALUE_NUM_CODE = {USD: "840", EUR: "978"}
URL = "http://www.cbr.ru/scripts/XML_daily.asp"

def dual_currency_balancer (ruble, dollar, usd_value)
  difference = ruble / usd_value - dollar
  difference.abs < 0.01 ? 0.00 : (difference / 2).round(2)
end

usd_value =
  begin
    response = Net::HTTP.get_response(URI.parse(URL))
    doc = REXML::Document.new(response.body)
    volutes = doc.root.elements

    usd = volutes.find { |valute| valute.elements['NumCode'].text == VALUE_NUM_CODE[:USD] }
    usd.elements['Value'].text.gsub(',', '.').to_f
  rescue SocketError
    puts "Проблемы с подключением к сети :("
    puts "Введите курс доллара (вводить через точку, например: 64.55)"
    STDIN.gets.to_f
  rescue REXML::ParseException
    puts "Проблемы с чтением данных из сети :("
    puts "Введите курс доллара (вводить через точку, например: 64.55)"
    STDIN.gets.to_f
  end

puts "Курс доллара США на сегодня: #{usd_value} руб."

puts 'Сколько у вас рублей?'
ruble = gets.to_f

puts 'Сколько у вас долларов?'
dollar = gets.to_f

diff = dual_currency_balancer(ruble, dollar, usd_value)

if diff.zero?
  puts "Портфель сбалансирован."
else
  puts diff.positive? ? "Надо купить: #{diff}$" : "Надо продать: #{diff.abs}$"
end
