#encoding: utf-8

$chars = {}

def read_readings fn
	f = File.open(fn, 'r:utf-8')
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s[0] == '#'
		c, rs = s.split(/\t/)
		if c.ord > 0x9fa5 && c.ord <= 0xffff
			puts "#{c} - #{fn}"
			next
		end
		$chars[c] = {:edu => [], :ithuan => []} if !$chars.has_key?(c)
		yield $chars[c], rs ? rs.split(/, /) : []
	}
	f.close
end

#read_readings('han_taiyu.txt') {} 

read_readings('M_minnanyu_result.txt'){ |dt, rs|
	rs.each { |r| dt[:edu] << r }
}

read_readings('ithuan_readings.txt'){ |dt, rs|
	rs.each { |r| dt[:ithuan] << r if !dt[:edu].include?(r) }
}

f = File.open('readings_merged.txt', 'w:utf-8')
$chars.sort_by{ |c, v| c }.each { |c, v|
	f.print c + "\t"
	f.print v[:edu].join(', ') + "\t"
	f.print v[:ithuan].join(', ') + "\n"
}
f.close


#f = File.open('M_minnanyu_result.txt', 'r:utf-8')