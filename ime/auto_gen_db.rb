# encoding: utf-8

require 'json'
require 'set'
$gnmap_fn = '../readings/taigi_readings.txt'
$readings_fn = '../readings/readings_table.txt'
$dictionary_fn = '../readings/source/M_moe_minnanyu.txt'

tlmap = {}
readings = {}
data = {}

f = File.open($gnmap_fn, 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	next if s[0] == '#'
	
	tmp = s.split(/\t/)
	tlmap[tmp[0]] = tmp[3]
}
f.close

f = File.open($readings_fn, 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	next if s[0] == '#'
	
	tmp = s.split(/\t/)
	next if tmp.length <= 4

	c = tmp[0]
	readings[c] = tmp[3..-1].map{ |tl| tlmap[tl] }
	#p readings[c]
	len = readings[c].size
	data[c] = { vset: false, v: Array.new(len), tset: false, t: Array.new(len) }
}
f.close

doubled = Set.new

f = File.open($dictionary_fn, 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	next if s =~ /^\D/
	
	no, type, word, reading, d = s.split /\t/
	next if !reading
	next if reading == ''

	if word.length == 1
		reading.gsub!(/\/.+$/, '')
		c = word
		next if !readings.has_key?(c)

		if reading =~ /【([文白又替俗])】/
			tag = $1
			r = reading.gsub(/【([文白又替俗])】/, '')
			readings[c].size.times { |j|
				if readings[c][j] == r
					data[c][:t][j] = tag
					data[c][:tset] = true
					break
				end
			}
		end
	elsif word.length > 1 && word.length <= 4
		next if doubled === word
		rlist = reading.gsub(/\/.+$/, '').gsub(/--/, '=').split(/-/)
		next if rlist.size != word.length

		word.length.times { |i|
			c = word[i]
			r = rlist[i].gsub('=', '--')
			next if !readings.has_key?(c)

			readings[c].size.times { |j|
				#p "#{r} - #{readings[c][j]}"
				if readings[c][j] == r
					data[c][:v][j] = [] if data[c][:v][j] == nil
					data[c][:v][j] << word[0...i] + '*' + word[i+1..-1]
					data[c][:vset] = true
					break
				end
			}
		}
	end

	doubled << word
}
f.close

res = {}
data.each { |c, x|
	res[c] = { s: x[:v].size }

	if x[:vset]
		res[c][:v] = []
		x[:v].each { |vs|
			res[c][:v] << (vs != nil ? vs.sort_by{|s| -s.length }.join('/') : '')
		}
	end

	if x[:tset]
		res[c][:t] = x[:t].map{ |t| t ? t : ''}.join('/')
	end
}

puts "Write reading_db.js ..."
f = File.open('reading_db.js', 'w:utf-8')
f.puts 'var data = ' + JSON.pretty_generate(res)
f.close