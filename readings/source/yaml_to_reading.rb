#encoding: utf-8

$tlmap = {}
$chars = {}

f = File.open('hanlo.dict.yaml', 'r:utf-8')
f.each { |s|
	s.chomp!
	word, keys, rank = s.split(/\t/)
	next if rank.to_i == 0
	next if keys != keys.downcase
	
	if word[0].ord >= 0x3400
		# hanzi
		ks = keys.split(/ /)
		if word.length == ks.size
			ks.size.times { |i|
				next if ks[i][-1] == '6'
				next if ks[i] =~ /eng|ee|[eio]r/
				c = word[i]
				tl = $tlmap[ks[i]]
				$chars[c] = Hash.new(0) if !$chars.has_key?(c)
				$chars[c][tl] += 1
			}
		end
	elsif word[0].ord < 0x2000
		# latin
		ws = word.split(/-/)
		ks = keys.split(/ /)
		if ws.size == ks.size
			ws.size.times { |i|
				next if ks[i][-1] == '6'
				next if ks[i] =~ /eng|ee|[eio]r/
				print "Diff map at #{ks[i]}: #{ws[i]} / #{$tlmap[ks[i]]}" if $tlmap.has_key?(ks[i]) && $tlmap[ks[i]] != ws[i]
				$tlmap[ks[i]] = ws[i]
			}
		end
	end
}
f.close

f = File.open('ithuan_readings.txt', 'w:utf-8')
$chars.sort_by{ |c, v| c }.each { |c, v|
	f.print c + "\t"
	f.puts v.keys.sort_by{ |r| -v[r] }.join(', ')
}
f.close
