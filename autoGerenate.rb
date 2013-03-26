minterm = File.new('minterm','w')
dontknow = File.new('dontknow','w')

puts "This script will auto-generate the file minterm and dontknow."
puts "Input the number of variables:"

num = gets.strip.to_i

puts "Generating..."

minterm_list = []
dontknow_list = []

(0..2 ** num - 1).each do |i|
  if((rand = Random.rand) < 0.2)
    minterm_list << i
  elsif(rand > 0.8)
    dontknow_list << i
  end
end

minterm_list.each do |min|
  minterm.puts min
end

dontknow_list.each do |d|
  dontknow.puts d
end

minterm.close
dontknow.close

puts "done"
