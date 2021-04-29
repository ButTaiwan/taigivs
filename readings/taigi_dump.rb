#encoding: utf-8

#a	á (U+00E1)	à (U+00E0)	ah	â (U+00E2)	ǎ (U+01CE)	ā (U+0101)	a̍h (U+0061 U+030D)	a̋ (U+0061 U+030B)
#e	é (U+00E9)	è (U+00E8)	eh	ê (U+00EA)	ě (U+011B)	ē (U+0113)	e̍h (U+0065 U+030D)	e̋ (U+0065 U+030B)
#i	í (U+00ED)	ì (U+00EC)	ih	î (U+00EE)	ǐ (U+01D0)	ī (U+012B)	i̍h (U+0069 U+030D)	i̋ (U+0069 U+030B)
#o	ó (U+00F3)	ò (U+00F2)	oh	ô (U+00F4)	ǒ (U+01D2)	ō (U+014D)	o̍h (U+006F U+030D)	ő (U+0151)
#u	ú (U+00FA)	ù (U+00F9)	uh	û (U+00FB)	ǔ (U+01D4)	ū (U+016B)	u̍h (U+0075 U+030D)	ű (U+0171)
#m	ḿ (U+1E3F)	m̀ (U+006D U+0300)	mh	m̂ (U+006D U+0302)	m̌ (U+006D U+030C)	m̄ (U+006D U+0304)	m̍h (U+006D U+030D)	m̋ (U+006D U+030B)
#n	ń (U+0144)	ǹ (U+01F9)	nh	n̂ (U+006E U+0302)	ň (U+0148)	n̄ (U+006E U+0304)	n̍h (U+006E U+030D)	n̋ (U+006E U+030B)

def roman_to_gnlist src
	str = src+''
	str.gsub!('á', ' *aacute ')
	str.gsub!('é', ' *eacute ')
	str.gsub!('í', ' *iacute ')
	str.gsub!('ó', ' *oacute ')
	str.gsub!('ú', ' *uacute ')
	str.gsub!('ḿ', ' *macute ')
	str.gsub!('ń', ' *nacute ')
	str.gsub!("o\u0358\u0301", ' *oo-poj_acutecomb ')

	str.gsub!('à', ' *agrave ')
	str.gsub!('è', ' *egrave ')
	str.gsub!('ì', ' *igrave ')
	str.gsub!('ò', ' *ograve ')
	str.gsub!('ù', ' *ugrave ')
	str.gsub!('m̀', ' *m_gravecomb ')
	str.gsub!('ǹ', ' *ngrave ')
	str.gsub!("o\u0358\u0300", ' *oo-poj_gravecomb ')

	str.gsub!('â', ' *acircumflex ')
	str.gsub!('ê', ' *ecircumflex ')
	str.gsub!('î', ' *icircumflex ')
	str.gsub!('ô', ' *ocircumflex ')
	str.gsub!('û', ' *ucircumflex ')
	str.gsub!('m̂', ' *m_circumflexcomb ')
	str.gsub!('n̂', ' *n_circumflexcomb ')
	str.gsub!("o\u0358\u0302", ' *oo-poj_circumflexcomb ')

	str.gsub!('ā', ' *amacron ')
	str.gsub!('ē', ' *emacron ')
	str.gsub!('ī', ' *imacron ')
	str.gsub!('ō', ' *omacron ')
	str.gsub!('ū', ' *umacron ')
	str.gsub!('m̄', ' *m_macroncomb ')
	str.gsub!('n̄', ' *n_macroncomb ')
	str.gsub!("o\u0358\u0304", ' *oo-poj_macroncomb ')

	str.gsub!('a̍', ' *a_verticallineabovecomb ')
	str.gsub!('e̍', ' *e_verticallineabovecomb ')
	str.gsub!('i̍', ' *i_verticallineabovecomb ')
	str.gsub!('o̍', ' *o_verticallineabovecomb ')
	str.gsub!('u̍', ' *u_verticallineabovecomb ')
	str.gsub!('m̍', ' *m_verticallineabovecomb ')
	str.gsub!('n̍', ' *n_verticallineabovecomb ')
	str.gsub!("o\u0358\u030d", ' *oo-poj_verticallineabovecomb ')

	str.gsub!('a̋', ' *a_hungarumlautcomb ')
	str.gsub!('e̋', ' *e_hungarumlautcomb ')
	str.gsub!('i̋', ' *i_hungarumlautcomb ')
	str.gsub!('ő', ' *ohungarumlaut ')
	str.gsub!('ű', ' *uhungarumlaut ')
	str.gsub!('m̋', ' *m_hungarumlautcomb ')
	str.gsub!('n̋', ' *n_hungarumlautcomb ')
	str.gsub!("o\u0358\u030b", ' *oo-poj_hungarumlautcomb ')

	str.gsub!('ă', ' *abreve ')
	str.gsub!('ĕ', ' *ebreve ')
	str.gsub!('ĭ', ' *ibreve ')
	str.gsub!('ŏ', ' *obreve ')
	str.gsub!('ŭ', ' *ubreve ')
	str.gsub!('m̆', ' *m_brevecomb ')
	str.gsub!('n̆', ' *n_brevecomb ')
	str.gsub!("o\u0358\u0306", ' *oo-poj_brevecomb ')

	str.gsub!("o\u0358", ' *oo-poj_acutecomb ')
	str.gsub!("ⁿ", ' *nmod ')

	res = []
	str.split(' ').each { |s|
		next if s == ''
		if s[0] == '*'
			res << s[1..-1]
		else
			s.each_char { |c| 
				if c == '-'
					res << 'minus'
				elsif c =~ /[a-z]/
					res << c
				else
					res << '?' + c.ord.to_s(16)
					puts "Error #{str} - #{c}"
				end
			}
		end
	}

	res.join('_')
end

def bpm_to_gnlist src
	str = src+''
	str.gsub!(/ㆴ8/, ' *cid670 ')
	str.gsub!(/ㆵ8/, ' *cid671 ')
	str.gsub!(/ㆷ8/, ' *cid673 ')
	str.gsub!(/ㆻ8/, ' *cid674 ')

	res = []
	str.split(' ').each { |s|
		next if s == ''
		if s[0] == '*'
			res << s[1..-1]
		else
			s.each_char { |c| 
				if c == '˙'
					res << 'uni02D9'
				elsif c == 'ˊ'
					res << 'cid460'
				elsif c == 'ˋ'
					res << 'cid462'
				elsif c == '˪'
					res << 'cid463'
				elsif c == '˫'
					res << 'cid464'
				elsif c == 'ㆴ'
					res << 'cid465'
				elsif c == 'ㆵ'
					res << 'cid466'
				elsif c == 'ㆷ'
					res << 'cid468'
				elsif c == 'ㆵ'
					res << 'cid469'
				elsif c =~ /[ㄅ-ㄫㆠ-ㆻ]/
					res << 'uni' + c.ord.to_s(16).upcase
				else
					res << '?' + c.ord.to_s(16)
					puts "Error #{str} - #{c}"
				end
			}
		end
	}

	res.join('_')
end

def gn_to_bpm gn
	bpm = gn.gsub(/[014]/, '')
	bpm.gsub!('2', 'ˋ')
	bpm.gsub!('3', '˪')
	bpm.gsub!('5', 'ˊ')
	bpm.gsub!('7', '˫')
	#bpm.gsub!('8', "\u0307")
	#bpm.gsub!('8', "˙")
	
	#ㄅ	ㆠ	ㄆ	ㄇ	ㄉ	ㄊ	ㄋ	ㄌ	ㄍ	ㆣ	ㄎ	ㄫ	ㄏ	ㄐ	ㆢ	ㄑ	ㄒ	ㄗ	ㆡ	ㄘ	ㄙㄏ̇
	#ㄚ	ㆩ	ㆦ	ㆧ	ㄜ	ㆤ	ㆥ	ㄞ	ㆮ	ㄠ	ㆯ	ㆰ	ㆱ	ㆬ	ㄢ	ㄣ	ㄤ	ㆲ	ㄥ	ㆭ	ㄧ	ㆪ	ㄨ	ㆫ
	
	# 聲母
	bpm.gsub!(/^ph/, 'ㄆ')
	bpm.gsub!(/^th/, 'ㄊ')
	bpm.gsub!(/^ng(?=[aeiou])/, 'ㄫ')
	bpm.gsub!(/^kh/, 'ㄎ')
	bpm.gsub!(/^tsh(?=i)/, 'ㄑ')
	bpm.gsub!(/^tsh/, 'ㄘ')
	bpm.gsub!(/^ts(?=i)/, 'ㄐ')
	bpm.gsub!(/^ts/, 'ㄗ')
	bpm.gsub!(/^j(?=i)/, 'ㆢ')
	bpm.gsub!(/^s(?=i)/, 'ㄒ')
	bpm.gsub!(/^p/, 'ㄅ')
	bpm.gsub!(/^b/, 'ㆠ')
	bpm.gsub!(/^m(?=[aeioun])/, 'ㄇ')
	bpm.gsub!(/^t/, 'ㄉ')
	bpm.gsub!(/^n(?=[aeioun])/, 'ㄋ')
	bpm.gsub!(/^l/, 'ㄌ')
	bpm.gsub!(/^k/, 'ㄍ')
	bpm.gsub!(/^g/, 'ㆣ')
	bpm.gsub!(/^h/, 'ㄏ')
	bpm.gsub!(/^j/, 'ㆡ')
	bpm.gsub!(/^s/, 'ㄙ')

	# 入聲
	bpm.gsub!(/(?<=.)p/, 'ㆴ')
	bpm.gsub!(/(?<=.)t/, 'ㆵ')
	bpm.gsub!(/(?<=.)k/, 'ㆻ')
	bpm.gsub!(/(?<=.)h/, 'ㆷ')

	# 韻母
	bpm.gsub!(/ann/, 'ㆩ')
	bpm.gsub!(/ang/, 'ㄤ')
	bpm.gsub!(/an/, 'ㄢ')
	bpm.gsub!(/am/, 'ㆰ')
	bpm.gsub!(/ainn/, 'ㆮ')
	bpm.gsub!(/ai/, 'ㄞ')
	bpm.gsub!(/aunn/, 'ㆯ')
	bpm.gsub!(/au/, 'ㄠ')
	bpm.gsub!(/am/, 'ㆰ')
	bpm.gsub!(/a/, 'ㄚ')
	bpm.gsub!(/enn/, 'ㆥ')
	bpm.gsub!(/e/, 'ㆤ')
	bpm.gsub!(/inn/, 'ㆪ')
	bpm.gsub!(/ing/, 'ㄧㄥ')
	bpm.gsub!(/i/, 'ㄧ')
	bpm.gsub!(/onn/, 'ㆧ')
	bpm.gsub!(/ong/, 'ㆲ')
	bpm.gsub!(/oo/, 'ㆦ')
	bpm.gsub!(/om/, 'ㆱ')
	bpm.gsub!(/o(?=[ㆴㆻ])/, 'ㆦ')
	bpm.gsub!(/o/, 'ㄜ')
	bpm.gsub!(/unn/, 'ㆫ')
	bpm.gsub!(/u/, 'ㄨ')
	bpm.gsub!(/ng/, 'ㆭ')
	bpm.gsub!(/n/, 'ㄣ')
	bpm.gsub!(/m/, 'ㆬ')

	bpm = '˙' + bpm if gn =~ /0$/
	puts bpm if bpm =~ /[a-z0-79]/

	bpm
end

#將 o͘ (o + U+0358) 轉為 oo
#ch 變為 ts
#chh 變為 tsh
#所有的 oe 變為 ue
#所有的 oa 變為 ua
#所有結尾的 ek 變成 ik
#所有的 eng 變成 ing
#ⁿ 寫成 nn

def tl_to_poj tl
	poj = tl.gsub('oo', "o\u0358")
	poj.gsub!('óo', "o\u0358\u0301")
	poj.gsub!('òo', "o\u0358\u0300")
	poj.gsub!('ôo', "o\u0358\u0302")
	poj.gsub!('ōo', "o\u0358\u0304")
	poj.gsub!('o̍o', "o\u0358\u030d")
	
	poj.gsub!('ts', "ch")

	poj.gsub!(/u(?=[aáàâāeéèêē])/, "o")

	poj.gsub!(/oá(?![ihnt])/, "óa")
	poj.gsub!(/oà(?![ihnt])/, "òa")
	poj.gsub!(/oâ(?![ihnt])/, "ôa")
	poj.gsub!(/oā(?![ihnt])/, "ōa")

	poj.gsub!(/oé(?!h)/, "óe")
	poj.gsub!(/oè(?!h)/, "òe")
	poj.gsub!(/oê(?!h)/, "ôe")
	poj.gsub!(/oē(?!h)/, "ōe")
	
	poj.gsub!(/ik/, "ek")
	poj.gsub!(/i̍k/, "e̍k")
	
	poj.gsub!(/ing/, "eng")
	poj.gsub!(/íng/, "éng")
	poj.gsub!(/ìng/, "èng")
	poj.gsub!(/îng/, "êng")
	poj.gsub!(/īng/, "ēng")

	poj.gsub!(/nnh/, "hⁿ")
	poj.gsub!(/nn(?=[ptk1-9])/, "ⁿ")

	poj.gsub!(/a̋/, 'ă')
	poj.gsub!(/e̋/, 'ĕ')
	poj.gsub!(/i̋/, 'ĭ')
	poj.gsub!(/ő/, 'ŏ')
	poj.gsub!(/ű/, 'ŭ')
	poj.gsub!("\u030b", "\u0306")

	poj
end

def tl_to_gn tl
	tone = 1
	latin = ''
	light = ''
	
	tlx = tl
	if tlx =~ /^--/
		light = '0'
		tlx = tlx.gsub(/^--/, '')
	end

	tone = 4 if tl =~ /[pkth]$/
	
	tlx.each_char { |c|
		if c =~ /[a-z]/
			latin += c
		elsif c == 'á'
			latin, tone = latin + 'a', 2
		elsif c == 'à'
			latin, tone = latin + 'a', 3
		elsif c == 'â'
			latin, tone = latin + 'a', 5
		elsif c == 'ā'
			latin, tone = latin + 'a', 7
		elsif c == 'é'
			latin, tone = latin + 'e', 2
		elsif c == 'è'
			latin, tone = latin + 'e', 3
		elsif c == 'ê'
			latin, tone = latin + 'e', 5
		elsif c == 'ē'
			latin, tone = latin + 'e', 7
		elsif c == 'í'
			latin, tone = latin + 'i', 2
		elsif c == 'ì'
			latin, tone = latin + 'i', 3
		elsif c == 'î'
			latin, tone = latin + 'i', 5
		elsif c == 'ī'
			latin, tone = latin + 'i', 7
		elsif c == 'ó'
			latin, tone = latin + 'o', 2
		elsif c == 'ò'
			latin, tone = latin + 'o', 3
		elsif c == 'ô'
			latin, tone = latin + 'o', 5
		elsif c == 'ō'
			latin, tone = latin + 'o', 7
		elsif c == 'ő'
			latin, tone = latin + 'o', 9
		elsif c == 'ú'
			latin, tone = latin + 'u', 2
		elsif c == 'ù'
			latin, tone = latin + 'u', 3
		elsif c == 'û'
			latin, tone = latin + 'u', 5
		elsif c == 'ū'
			latin, tone = latin + 'u', 7
		elsif c == 'ű'
			latin, tone = latin + 'u', 9
		elsif c == 'ḿ'
			latin, tone = latin + 'm', 2
		elsif c == 'ń'
			latin, tone = latin + 'n', 2
		elsif c == 'ǹ'
			latin, tone = latin + 'n', 3
#		elsif c.ord == 0x301
#			puts tl
#			tone = 2
		elsif c.ord == 0x300
			tone = 3
		elsif c.ord == 0x302
			tone = 5
		elsif c.ord == 0x304
			tone = 7
		elsif c.ord == 0x30d
			tone = 8
		elsif c.ord == 0x30b
			tone = 9
		else
			p "Unknown: #{tl} - #{c.ord.to_s(16)}"
		end
	}

	"#{latin}#{tone}#{light}"
end

$xxx = Hash.new(0)

$tls = Hash.new('')
$cnt = Hash.new(0)

f = File.open('readings_merged.txt', 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	
	c, pstr = s.split(/\t/, 2)
	pstr.gsub(/[」　？]/, '').split(/\t|, /).each { |ph|
		next if ph == ''
		$xxx[ph] += 1

		gn = tl_to_gn(ph)
		puts "#{ph} - #{$tls[key]}" if $tls[gn] != '' && $tls[gn] != ph
		$tls[gn] = ph
		$cnt[gn] += 1
	}
}
f.close

puts $xxx.size
puts $tls.size
puts $cnt.size

f = File.open('taigi_readings.txt', 'w:utf-8')
$tls.sort_by{|k, v| k}.each {|k, v|
	poj = tl_to_poj v
	bpm = gn_to_bpm k

	tlgn = roman_to_gnlist v
	pojgn = roman_to_gnlist poj
	bpmgn = bpm_to_gnlist bpm

	f.puts "#{k}\t#{$cnt[k]}\t#{v}\t#{tlgn}\t#{poj}\t#{pojgn}\t#{bpm}\t#{bpmgn}"
}
f.close

