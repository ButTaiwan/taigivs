#encoding: utf-8

def simplfy_data f_in, f_out
	puts "Simplfy #{f_in}..."
	# to single line
	# remove spaces, symbols
	
	tflag = false
	
	f = File.open(f_in, 'r:utf-8')
	o = File.open(f_out, 'w:utf-8')
	f.each { |s|
		s.chomp!
		s.split(/\t/).each { |t|
			if tflag && t[-1] == '"'
				o.print t[0..-2] + "\t"
				tflag = false
			elsif t[0] == '"'
				tflag = true
				o.print t[1..-1] + " "
			else
				o.print t + (tflag ? " " : "\t")
			end
		}
		o.puts unless tflag
	}
	o.close
	f.close
end

def extracting f_in, f_out, wd_col, ph_col, zdmode = false
	f = File.open(f_in, 'r:utf-8')
	chars = Hash.new(false)
	c = 0
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s =~ /^\D/ && !zdmode
		tmp = s.split(/\t/)
		next if tmp[wd_col] =~ /\&/
		wd = tmp[wd_col].gsub(/[ ，。．˙；]/, '').gsub('（', '(').gsub('）', ')').gsub(/\([^一-龘]+\)/, '').split(//)
		
		pseq = tmp[ph_col].gsub('（', '(').gsub('）', ')').gsub(/[，。；]/, '').gsub('　', ' ').gsub(/([ㄓ-ㄩˊˇˋ])ㄦ/, '\1 ㄦ').gsub(/([ˊˋˇ])(\S)/, '\1 \2')
							.gsub(/^(\([一二三四五六七八九讀語又]音?\))+/, '').gsub(/\s*\([ㄅ-ㄩˊˇˋ˙ ]+\)/, '').gsub(/ +/, ' ')
		plist = zdmode ? pseq.split(/ +/) : pseq.split(/\([變又讀語]音?\)/)
		#ph = tmp[ph_col].gsub(/（變）.+$/, '').gsub(/\([一二三四五六七八九讀語又]\)/, '').split(/　/)
		
		plist.each { |pstr|
			pstr.gsub!('一', 'ㄧ')
			p pstr if pstr =~ /[^ㄅ-ㄩˊˇˋ˙ ]/
			ph = pstr.split(/ /)
			
			if wd.length == ph.length
				wd.length.times { |i|
					chars[wd[i]] = Hash.new(0) if !chars[wd[i]]
					chars[wd[i]][ph[i]] += 1
				}
			else
				p wd, tmp[ph_col], plist, pstr, ph
				c += 1
				exit if c > 10
			end
		}
	}
	f.close
	
	f = File.open(f_out, 'w:utf-8')
	chars.sort_by{ |ch, phs| ch }.each { |ch, phs|
		rstr = phs.sort_by{ |ph, cnt| -cnt }.map{ |ph, cnt| ph }.join(' ／ ')
		f.puts "#{ch}\t#{rstr}"
	}
	f.close
end

def load_puas
	res = {}
	f = File.open('0_tauhu_pua.txt', 'r:utf-8')
	f.each { |s|
		tmp = s.split /\t/
		res[tmp[0]] = tmp[2]
	}
	f.close
	res
end

def add_minnan chars, str, read, light
	clist = str.gsub(/\s/, '').gsub(/[　，。、！？；「」：─]/, '').split(//)
	reads = read.gsub(/【\S+?】/, '').gsub(/[\.,\!\?\;\"\:─]/, ' ').gsub(/[\-‑，]+/, ' ').gsub(/^\s+|\s+$/, '').gsub('～', '--').split(/\s+/)
	if clist.length != reads.length
		p clist, reads 
	else
		clist.length.times { |i|
			next if (!light) && reads[i] =~ /^--/
			c = $puas.has_key?(clist[i]) ? $puas[clist[i]] : clist[i]
			chars[c] = Hash.new(0) if !chars[c]
			chars[c][reads[i].downcase] += 1
		}
	end
end

def extracting_minnan f_in, f_out
	f = File.open(f_in, 'r:utf-8')
	chars = Hash.new(false)
	c = 0
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s =~ /^\D/
		s.gsub!(/ /, ' ')
		s.gsub!(/--/, ' ～')
		
		tmp = s.split(/\t/)
		if tmp[3] && tmp[3] != ''
			tmp[3].split(/[\/、]/).each { |r|
				add_minnan(chars, tmp[2], r, true)
			}
		end
		if tmp[6] && tmp[6] != ''
			tmp[6].split(/[\/、]/).each { |r|
				add_minnan(chars, tmp[2], r, true)
			}
		end
		
		s.scan(/例：([^a-zA-Z]+)[　。！？]([^\(。、；　]+)/).each { |m|
			add_minnan(chars, m[0], m[1], false)
		}
	}
	f.close
	
	f = File.open(f_out, 'w:utf-8')
	chars.sort_by{ |ch, phs| ch }.each { |ch, phs|
		rstr = phs.sort_by{ |ph, cnt| -cnt }.map{ |ph, cnt| ph }.join(', ')
		f.puts "#{ch}\t#{rstr}"
	}
	f.close
end

def add_kejia chars, str, type, read
	return if !read
	return if read == ''
	puts read if read =~ /[^a-zˇˊˋ^\+ ]/
	
	clist = str.gsub(/[\s－─，。、！？；「」：]/, '').split(//)
	reads = read.split(/\s+/)
	#clist = str.gsub(/\s/, '').gsub(/[　，。、！？；「」：─]/, '').split(//)
	#reads = read.gsub(/【\S+?】/, '').gsub(/[\.,\!\?\;\"\:─]/, ' ').gsub(/[\-‑，]+/, ' ').gsub(/^\s+|\s+$/, '').gsub('～', '--').split(/\s+/)
	
	if clist.length != reads.length
		p clist, reads 
	else
		clist.length.times { |i|
			#next if (!light) && reads[i] =~ /^--/
			c = $puas.has_key?(clist[i]) ? $puas[clist[i]] : clist[i]
			next if c == '□'
			#r = '[' + type + '] ' + 
			chars[c] = Hash.new(false) if !chars[c]
			chars[c][type] = Hash.new(0) if !chars[c][type]
			chars[c][type][reads[i].downcase] += 1
		}
	end
end

def extracting_kejia f_in, f_out
	res = {}
	f = File.open(f_in, 'r:utf-8')
	chars = Hash.new(false)
	c = 0
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s =~ /^\D/
		#s.gsub!(/ /, ' ')
		
		tmp = s.split(/\t/)
		
		add_kejia(chars, tmp[1], '1四縣', tmp[3])
		add_kejia(chars, tmp[1], '2海陸', tmp[5])
		add_kejia(chars, tmp[1], '3大埔', tmp[7])
		add_kejia(chars, tmp[1], '4饒平', tmp[9])
		add_kejia(chars, tmp[1], '5詔安', tmp[11])
		add_kejia(chars, tmp[1], '6南四縣', tmp[13])
	}
	f.close
	
	f = File.open(f_out, 'w:utf-8')
	chars.sort_by{ |ch, types| ch }.each { |ch, types|
		buff = []
		types.sort_by{ |t, phs| t }.each { |t, phs|
			buff << '[' + t[1..-1] + '] ' + phs.sort_by{ |ph, cnt| -cnt }.map{ |ph, cnt| ph }.join(', ')
		}
		f.puts "#{ch}\t#{buff.join(' ')}"
	}
	f.close
end

$puas = load_puas

#extracting 'B_moe_chongbian_single.txt', 'B_chongbian_result.txt', 2, 6
#extracting 'C_moe_jianbian_single.txt', 'C_ph_result.txt', 1, 5
#extracting 'E_moe_xiaozidian_single.txt', 'E_xiaozidian_result.txt', 0, 4, true
#extracting_minnan 'M_moe_minnanyu.txt', 'M_minnanyu_result.txt'
extracting_kejia 'N_moe_kejia.txt', 'N_kejia_result.txt'

#simplfy_data('E_moe_xiaozidian.txt', 'E_moe_xiaozidian_single.txt');