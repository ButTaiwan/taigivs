#encoding: utf-8

$tl2gn = {}

f = File.open('taigi_readings.txt', 'r:utf-8')
o1 = File.open('glist_tl.txt', 'w:utf-8')
o2 = File.open('glist_poj.txt', 'w:utf-8')
o3 = File.open('glist_bpm.txt', 'w:utf-8')
f.each { |s|
	s.chomp!
	
	gn, cnt, tl, tlgn, poj, pojgn, bpm, bpmgn = s.split(/\t/)
	$tl2gn[tl] = gn
	
	o1.puts "#{gn}=" + tlgn.gsub('_', '+')
	o2.puts "#{gn}=" + pojgn.gsub('_', '+')
	o3.puts "#{gn}=" + bpmgn.gsub('_', '+')
}
o1.close
o2.close
o3.close
f.close

f = File.open('readings_merged.txt', 'r:utf-8')
o = File.open('readings_table.txt', 'w:utf-8')
f.each { |s|
	s.chomp!
	
	c, edu, ith = s.split(/\t/)
	u = c.ord.to_s(16).upcase

	t = edu != '' ? 'A' : ''
	t += 'B' if ith != nil && ith != ''
	
	o.print "#{c}\t#{u}\t#{t}"
	if edu != ''
		edu.split(/, /).each { |tl|
			#puts tl
			o.print "\t" + $tl2gn[tl]
		}
	end
	if ith != nil && ith != ''
		ith.split(/, /).each { |tl|
			o.print "\t*" + $tl2gn[tl]
		}
	end
	o.puts
}
o.close
f.close
