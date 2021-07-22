#encoding: utf-8

# 從 logical_syllables.txt 讀取所有邏輯上可能的音節
#	自動轉台羅
# 讀取 readings_merged.txt 漢字讀音表，加入漏掉的特殊音節
# 讀取 linked_sounds.txt，加入缺少的特殊合音音節

# 輸出 taigi_readings.txt，各種讀音資料 (台羅、POJ、方音、假名?)
# 輸出 glist_*.txt 轉換為這種 Glyphs 字符連結定義
# 輸出 readings_table.txt，以 Glyph name 命名的漢字讀音表

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
		# elsif c.ord == 0x301
		# 	puts tl
		# 	tone = 2
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

#a	á (U+00E1)	à (U+00E0)	ah	â (U+00E2)	ǎ (U+01CE)	ā (U+0101)	a̍h (U+0061 U+030D)	a̋ (U+0061 U+030B)
#e	é (U+00E9)	è (U+00E8)	eh	ê (U+00EA)	ě (U+011B)	ē (U+0113)	e̍h (U+0065 U+030D)	e̋ (U+0065 U+030B)
#i	í (U+00ED)	ì (U+00EC)	ih	î (U+00EE)	ǐ (U+01D0)	ī (U+012B)	i̍h (U+0069 U+030D)	i̋ (U+0069 U+030B)
#o	ó (U+00F3)	ò (U+00F2)	oh	ô (U+00F4)	ǒ (U+01D2)	ō (U+014D)	o̍h (U+006F U+030D)	ő (U+0151)
#u	ú (U+00FA)	ù (U+00F9)	uh	û (U+00FB)	ǔ (U+01D4)	ū (U+016B)	u̍h (U+0075 U+030D)	ű (U+0171)
#m	ḿ (U+1E3F)	m̀ (U+006D U+0300)	mh	m̂ (U+006D U+0302)	m̌ (U+006D U+030C)	m̄ (U+006D U+0304)	m̍h (U+006D U+030D)	m̋ (U+006D U+030B)
#n	ń (U+0144)	ǹ (U+01F9)	nh	n̂ (U+006E U+0302)	ň (U+0148)	n̄ (U+006E U+0304)	n̍h (U+006E U+030D)	n̋ (U+006E U+030B)

$latinmap = {
	'a' => [nil, 'a', 'á', 'à', 'a', 'â', 'ǎ', 'ā', 'a̍', 'a̋', 'ă'],
	'e' => [nil, 'e', 'é', 'è', 'e', 'ê', 'ě', 'ē', 'e̍', 'e̋', 'ĕ'],
	'i' => [nil, 'i', 'í', 'ì', 'i', 'î', 'ǐ', 'ī', 'i̍', 'i̋', 'ĭ'],
	'o' => [nil, 'o', 'ó', 'ò', 'o', 'ô', 'ǒ', 'ō', 'o̍', 'ő', 'ŏ'],
	'u' => [nil, 'u', 'ú', 'ù', 'u', 'û', 'ǔ', 'ū', 'u̍', 'ű', 'ŭ'],
	'm' => [nil, 'm', 'ḿ', 'm̀', 'm', 'm̂', 'm̌', 'm̄', 'm̍', 'm̋', 'm̆'],
	'n' => [nil, 'n', 'ń', 'ǹ', 'n', 'n̂', 'ň', 'n̄', 'n̍', 'n̋', 'n̆'],
	"\u0358" => [nil, "\u0358", "\u0358\u0301", "\u0358\u0300", "\u0358", "\u0358\u0302", "\u0358\u030c", "\u0358\u0304", "\u0358\u030d", "\u0358\u030b", "\u0358\u0306"]
}

$bpmfgns = {
	'ㄅ' => 'b', 'ㄆ' => 'p', 'ㄇ' => 'm', 'ㄉ' => 'd', 'ㄊ' => 't', 'ㄋ' => 'n', 'ㄌ' => 'l',
	'ㄍ' => 'g', 'ㄎ' => 'k', 'ㄏ' => 'h', 'ㄐ' => 'j', 'ㄑ' => 'q', 'ㄒ' => 'x',
	'ㄗ' => 'z', 'ㄘ' => 'c', 'ㄙ' => 's', 'ㄧ' => 'i', 'ㄨ' => 'u', 
	'ㄚ' => 'a', 'ㄜ' => 'e', 'ㄞ' => 'ai', 'ㄠ' => 'au', 'ㄢ' => 'an', 'ㄣ' => 'en', 'ㄤ' => 'ang', 'ㄥ' => 'eng', 'ㄫ' => 'ng', 
	'ㆠ' => 'bu', 'ㆡ' => 'zi', 'ㆢ' => 'ji', 'ㆣ' => 'gu', 'ㆤ' => 'ee', 'ㆥ' => 'enn', 
	'ㆦ' => 'oo', 'ㆧ' => 'onn', 'ㆨ' => 'ir', 'ㆩ' => 'ann', 'ㆪ' => 'inn', 'ㆫ' => 'unn',  
	'ㆬ' => 'im', 'ㆭ' => 'ngg', 'ㆮ' => 'ainn', 'ㆯ' => 'aunn', 'ㆰ' => 'am', 'ㆱ' => 'om', 'ㆲ' => 'ong',
	'ㆴ' => 'finalp', 'ㆵ' => 'finalt', 'ㆷ' => 'finalh', 'ㆻ' => 'finalg'

	# 'ㄈ' => 'f', 'ㄓ' => 'zh', 'ㄔ' => 'ch', 'ㄕ' => 'sh', 'ㄖ' => 'r', 'ㄛ' => 'o', 
	# 'ㄝ' => 'eh', 'ㄟ' => 'ei', 'ㄡ' => 'ou', 'ㄥ' => 'eng', 'ㄦ' => 'er', 'ㄩ' => 'iu',
}

$kanasmallgns = {
	'ァ' => 'asmall', 'ィ' => 'ismall', 'ゥ' => 'usmall', 'ェ' => 'esmall', 'ォ' => 'osmall', 'ッ' => 'tusmall', 'ㇰ' => 'kusmall'
}

$kanagns = {
	'ア' =>  'a', 'イ' =>  'i', 'ウ' =>  'u', 'エ' =>  'e', 'オ' =>  'o', 'ヲ' => 'wo',
	'カ' => 'ka', 'キ' => 'ki', 'ク' => 'ku', 'ケ' => 'ke', 'コ' => 'ko', 
	'ガ' => 'ga', 'ギ' => 'gi', 'グ' => 'gu', 'ゲ' => 'ge', 'ゴ' => 'go', 
	'サ' => 'sa', 'シ' => 'si', 'ス' => 'su', 'セ' => 'se', 'ソ' => 'so', 
	'ザ' => 'za', 'ジ' => 'zi', 'ズ' => 'zu', 'ゼ' => 'ze', 'ゾ' => 'zo', 
	'タ' => 'ta', 'チ' => 'ti', 'ツ' => 'tu', 'テ' => 'te', 'ト' => 'to', 
	'ダ' => 'da', 'ヂ' => 'di', 'ヅ' => 'du', 'デ' => 'de', 'ド' => 'do', 
	'ナ' => 'na', 'ニ' => 'ni', 'ヌ' => 'nu', 'ネ' => 'ne', 'ノ' => 'no', 
	'ハ' => 'ha', 'ヒ' => 'hi', 'フ' => 'hu', 'ヘ' => 'he', 'ホ' => 'ho', 
	'パ' => 'pa', 'ピ' => 'pi', 'プ' => 'pu', 'ペ' => 'pe', 'ポ' => 'po', 
	'バ' => 'ba', 'ビ' => 'bi', 'ブ' => 'bu', 'ベ' => 'be', 'ボ' => 'bo', 
	'マ' => 'ma', 'ミ' => 'mi', 'ム' => 'mu', 'メ' => 'me', 'モ' => 'mo', 
	'ラ' => 'ra', 'リ' => 'ri', 'ル' => 'ru', 'レ' => 're', 'ロ' => 'ro', 'ン' => 'n'
}

$kanacids = {
	'ㇷ' => 'cid64746', 'ㇻ' => 'cid00610' 
}

#Sound = Struct:new(:gn, :tl, :poj, :bpm)
class Sound
	attr_reader :gn, :body, :tone, :light, :type, :tl, :poj, :bpm, :kana
	attr_accessor :cnt

	def initialize(gn, type)
		raise "Wrong glyphname #{gn}" if gn =~ /[^a-z0-9]/
		@gn = gn
		@light = gn =~ /0/
		@tone = gn.gsub(/[a-z0]/, '').to_i
		raise "Wrong tone #{@tone} at #{gn}" if !(1..9).include?(@tone)
		@body = gn.gsub(/[0-9]/, '')
		@type = type
		@cnt = 0

		@tl = self.gn_to_tl
		@poj = self.gn_to_poj
		@bpm = self.gn_to_bpm
		@kana = self.gn_to_kana
	end

	def set_tone(str, pos, poj=false)
		c = str[pos]
		cx = $latinmap[c][@tone == 9 && poj ? 10 : @tone]
		return (@light ? '--' : '') + str[0...pos] + cx + str[pos+1..-1]
	end

	def gn_to_tl
		# 響度優先順序： a > oo > e = o > i = u〈低元音 > 高元音 > 無擦通音 > 擦音 > 塞音〉
		# iu 及 ui ，調號都標在後一個字母，因為前一個字母是介音。
		# m 作韻腹時標於字母 m 上。
		# 雙字母 oo 及 ng，標於前一個字母。
		# 三合字母 ere，標於最後的字母 e。
	
		return set_tone(@body, @body.index('a')) if @body.index('a')
		return set_tone(@body, @body.index('oo')) if @body.index('oo')
		return set_tone(@body, @body.index('e')) if @body.index('e')
		return set_tone(@body, @body.index('o')) if @body.index('o')
		return set_tone(@body, @body.index('ui')+1) if @body.index('ui')
		return set_tone(@body, @body.index('iu')+1) if @body.index('iu')
		return set_tone(@body, @body.index('i')) if @body.index('i')
		return set_tone(@body, @body.index('u')) if @body.index('u')
		return set_tone(@body, @body.index('ng')) if @body.index('ng')
		return set_tone(@body, @body.index('m')) if @body.index('m')
		puts "Error: unknown syllable #{@body}."
		return @body
	end

	def gn_to_poj
		# 將 o͘ (o + U+0358) 轉為 oo
		# ch 變為 ts
		# chh 變為 tsh
		# 所有的 oe 變為 ue
		# 所有的 oa 變為 ua
		# 所有結尾的 ek 變成 ik
		# 所有的 eng 變成 ing
		# ⁿ 寫成 nn

		# 順序：o＞e＞a＞u＞i＞ng＞m，ng 標在 n 上。
		# 例外
		# oai、oan、oat、oah 標在 a 上。
		# oeh 標在 e 上。

		str = @body + ''
		str.gsub!(/oo/, "o͘")
		str.gsub!(/ing$/, "eng")
		str.gsub!(/ik$/, "ek")
		str.gsub!(/nnh$/, "hⁿ")
		str.gsub!(/nn$/, "ⁿ")
		str.gsub!(/ts/, "ch")
		str.gsub!(/ue/, "oe")
		str.gsub!(/ua/, "oa")
	
		return set_tone(str, str.index('oa')+1, true) if str =~ /oa[inth]/
		return set_tone(str, str.index('oeh')+1, true) if str.index('oeh')
		return set_tone(str, str.index('o͘')+1, true) if str.index('o͘')
		return set_tone(str, str.index('o'), true) if str.index('o')
		return set_tone(str, str.index('e'), true) if str.index('e')
		return set_tone(str, str.index('a'), true) if str.index('a')
		return set_tone(str, str.index('u'), true) if str.index('u')
		return set_tone(str, str.index('i'), true) if str.index('i')
		return set_tone(str, str.index('ng'), true) if str.index('ng')
		return set_tone(str, str.index('m'), true) if str.index('m')
		puts "Error: unknown syllable #{@body}."
		return @body
	end

	def gn_to_bpm
		bpm = @gn.gsub(/[014]/, '')
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
		puts bpm if bpm =~ /[a-z0-7]/
	
		bpm
	end

	def gn_to_kana
		voiced = false
		
		str = @body + ''
		if str =~ /(?<=[aeiou])nn/
			str.gsub!(/(?<=[aeiou])nn/, '')
			voiced = true
		end
		voiced = true if str =~ /^(m|ng?)/
		voiced = true if str =~ /(?<=[^aeiou])(mh?|ngh?)$|^(mh?|ngh?)$/

		str.gsub!(/ue/, "oe")
		str.gsub!(/ua/, "oa")
		str.gsub!(/ian(?!g)$/, "ien")
		str.gsub!(/iat$/, "iet")
		str.gsub!(/ing/, "ieng")
		str.gsub!(/ik$/, "iek")

		str.gsub!(/(?<=a)h$/, 'ァ')
		str.gsub!(/(?<=i)h$/, 'ィ')
		str.gsub!(/(?<=u)h$/, 'ゥ')
		str.gsub!(/(?<=e)h$/, 'ェ')
		str.gsub!(/(?<=oo)h$/, 'ォ')
		str.gsub!(/(?<=o)h$/, 'ㇻ')
		#str.gsub!(/(?<=m)h$/, 'ㇺ')
		
		str.gsub!(/i(?=k|t|ng)$/, 'ェ')
		str.gsub!(/t$/, 'ッ')
		str.gsub!(/p$/, 'ㇷ')
		str.gsub!(/k$/, 'ㇰ')

		str.gsub!(/(?<=a)$/, 'ア')
		str.gsub!(/(?<=i)$/, 'イ')
		str.gsub!(/(?<=u)$/, 'ウ')
		str.gsub!(/(?<=e)$/, 'エ')
		str.gsub!(/(?<=oo)$/, 'オ')
		str.gsub!(/(?<=[^o]o)$/, 'ヲ')
		str.gsub!(/^o$/, 'oヲ')

		str.gsub!(/^ka/, 'カ')
		str.gsub!(/^ki/, 'キ')
		str.gsub!(/^ku/, 'ク')
		str.gsub!(/^k(?=ng)/, 'ク')
		str.gsub!(/^ke/, 'ケ')
		str.gsub!(/^koo?/, 'コ')
		str.gsub!(/^kha/, 'カ.')
		str.gsub!(/^khi/, 'キ.')
		str.gsub!(/^khu/, 'ク.')
		str.gsub!(/^kh(?=ng)/, 'ク.')
		str.gsub!(/^khe/, 'ケ.')
		str.gsub!(/^khoo?/, 'コ.')
		str.gsub!(/^n?ga/, 'ガ')
		str.gsub!(/^n?gi/, 'ギ')
		str.gsub!(/^n?gu/, 'グ')
		str.gsub!(/^n?g(?=ng)/, 'グ')
		str.gsub!(/^n?ge/, 'ゲ')
		str.gsub!(/^n?goo?/, 'ゴ')
		str.gsub!(/^sa/, 'サ')
		str.gsub!(/^si/, 'シ')
		str.gsub!(/^su/, 'ス')
		str.gsub!(/^s(?=ng)/, 'ス')
		str.gsub!(/^se/, 'セ')
		str.gsub!(/^soo?/, 'ソ')
		str.gsub!(/^ji/, 'ジ')
		str.gsub!(/^ju/, 'ズ')
		str.gsub!(/^j(?=ng)/, 'ズ')
		str.gsub!(/^je/, 'ゼ')
		str.gsub!(/^joo?/, 'ゾ')
		str.gsub!(/^tsa/, '|サ')
		str.gsub!(/^tsi/, 'チ')
		str.gsub!(/^tsu/, 'ツ')
		str.gsub!(/^ts(?=ng)/, 'ツ')
		str.gsub!(/^tse/, '|セ')
		str.gsub!(/^tsoo?/, '|ソ')
		str.gsub!(/^tsha/, '|サ.')
		str.gsub!(/^tshi/, 'チ.')
		str.gsub!(/^tshu/, 'ツ.')
		str.gsub!(/^tsh(?=ng)/, 'ツ.')
		str.gsub!(/^tshe/, '|セ.')
		str.gsub!(/^tshoo?/, '|ソ.')
		str.gsub!(/^ta/, 'タ')
		str.gsub!(/^ti/, '|チ')
		str.gsub!(/^tu/, '|ツ')
		str.gsub!(/^t(?=ng)/, '|ツ')
		str.gsub!(/^te/, 'テ')
		str.gsub!(/^too?/, 'ト')
		str.gsub!(/^tha/, 'タ.')
		str.gsub!(/^thi/, '|チ.')
		str.gsub!(/^thu/, '|ツ.')
		str.gsub!(/^th(?=ng)/, '|ツ.')
		str.gsub!(/^the/, 'テ.')
		str.gsub!(/^thoo?/, 'ト.')
		str.gsub!(/^na/, 'ナ')
		str.gsub!(/^ni/, 'ニ')
		str.gsub!(/^nu/, 'ヌ')
		str.gsub!(/^n(?=ng)/, 'ヌ')
		str.gsub!(/^ne/, 'ネ')
		str.gsub!(/^noo?/, 'ノ')
		str.gsub!(/^ha/, 'ハ')
		str.gsub!(/^hi/, 'ヒ')
		str.gsub!(/^hu/, 'フ')
		str.gsub!(/^h(?=ng|m)/, 'フ')
		str.gsub!(/^he/, 'ヘ')
		str.gsub!(/^hoo?/, 'ホ')
		str.gsub!(/^pa/, 'パ')
		str.gsub!(/^pi/, 'ピ')
		str.gsub!(/^pu/, 'プ')
		str.gsub!(/^p(?=ng)/, 'プ')
		str.gsub!(/^pe/, 'ペ')
		str.gsub!(/^poo?/, 'ポ')
		str.gsub!(/^pha/, 'パ.')
		str.gsub!(/^phi/, 'ピ.')
		str.gsub!(/^phu/, 'プ.')
		str.gsub!(/^ph(?=ng)/, 'プ.')
		str.gsub!(/^phe/, 'ペ.')
		str.gsub!(/^phoo?/, 'ポ.')
		str.gsub!(/^ba/, 'バ')
		str.gsub!(/^bi/, 'ビ')
		str.gsub!(/^bu/, 'ブ')
		str.gsub!(/^b(?=ng)/, 'ブ')
		str.gsub!(/^be/, 'ベ')
		str.gsub!(/^boo?/, 'ボ')
		str.gsub!(/^ma/, 'マ')
		str.gsub!(/^mi/, 'ミ')
		str.gsub!(/^mu/, 'ム')
		str.gsub!(/^m(?=ng)/, 'ム')
		str.gsub!(/^me/, 'メ')
		str.gsub!(/^moo?/, 'モ')
		str.gsub!(/^la/, 'ラ')
		str.gsub!(/^li/, 'リ')
		str.gsub!(/^lu/, 'ル')
		str.gsub!(/^l(?=ng)/, 'ル')
		str.gsub!(/^le/, 'レ')
		str.gsub!(/^loo?/, 'ロ')

		str.gsub!(/^a/, 'ア')
		str.gsub!(/^i/, 'イ')
		str.gsub!(/^u/, 'ウ')
		str.gsub!(/^e/, 'エ')
		str.gsub!(/^oo/, 'オ')
		str.gsub!(/^o(?=[ㇷッㇰmn])/, 'オ')
		str.gsub!(/^o/, 'ヲ')

		str.gsub!(/mh?$/, 'ム')
		str.gsub!(/ngh?$/, 'ン')
		str.gsub!(/n$/, 'ヌ')

		str.gsub!(/aア?$/, 'ア')
		str.gsub!(/iイ?$/, 'イ')
		str.gsub!(/uウ?$/, 'ウ')
		str.gsub!(/eエ?$/, 'エ')
		str.gsub!(/ooオ?$/, 'オ')
		str.gsub!(/oヲ?$/, 'ヲ')

		str.gsub!(/aァ?/, 'ァ')
		str.gsub!(/eェ?/, 'ェ')
		str.gsub!(/iィ?/, 'ィ')
		str.gsub!(/uゥ?/, 'ゥ')
		str.gsub!(/oㇻ/, 'ㇻ')
		str.gsub!(/oォ?/, 'ォ')

		#puts "#{@gn} #{str}" if str =~ /[a-z]/ || str.gsub(/[|.]/, '').length > 3
		return str + '⑴⑵⑶⑷⑸⑹⑺⑻⑼'[@tone-1]  if voiced
		return str if @tone == 1 
		return str + '２３４５６７８９'[@tone-2] 
	end

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
	
		str.gsub!("o\u0358", ' *oo-poj ')
		str.gsub!("ⁿ", ' *nmod ')
	
		res = []
		str.split(' ').each { |s|
			next if s == ''
			if s[0] == '*'
				res << s[1..-1]
			else
				s.each_char { |c| 
					if c == '-'
						res << 'shortminus'
					elsif c =~ /[a-z]/
						res << c
					else
						res << '?' + c.ord.to_s(16)
						puts "Error #{str} - #{c}"
					end
				}
			end
		}
	
		res.join('+')
	end

	def bpm_to_gnlist
		str = @bpm+''
		str.gsub!(/ㆴ8/, ' *finalp_dotaccent-bopomofo ')
		str.gsub!(/ㆵ8/, ' *finalt_dotaccent-bopomofo ')
		str.gsub!(/ㆷ8/, ' *finalh_dotaccent-bopomofo ')
		str.gsub!(/ㆻ8/, ' *finalg_dotaccent-bopomofo ')
		str.gsub!(/9/, ' *cid00475 ')
	
		res = []
		str.split(' ').each { |s|
			next if s == ''
			if s[0] == '*'
				res << s[1..-1]
			else
				s.each_char { |c| 
					if c == '˙'
						res << 'dotaccent'
					elsif c == 'ˊ'
						res << 'secondtonechinese' #'cid460'
					elsif c == 'ˋ'
						res << 'fourthtonechinese' #'cid462'
					elsif c == '˪'
						res << 'thirdtoneminnan' #'cid463'
					elsif c == '˫'
						res << 'senventhtoneminnan' #'cid464'
					# elsif c == 'ㆴ'
					# 	res << 'cid465'
					# elsif c == 'ㆵ'
					# 	res << 'cid466'
					# elsif c == 'ㆷ'
					# 	res << 'cid468'
					# elsif c == 'ㆵ'
					# 	res << 'cid469'
					elsif $bpmfgns.has_key?(c)
						res << $bpmfgns[c] + '-bopomofo'
						#res << 'uni' + c.ord.to_s(16).upcase
					else
						res << '?' + c.ord.to_s(16)
						puts "Error #{str} - #{c}"
					end
				}
			end
		}
	
		res.join('+')
	end

	$kanacids = {
		'ㇷ' => 'cid64746', 'ㇻ' => 'cid00610' 
	}

	def kana_to_gnlist
		res = []
		@kana.each_char { |c|
			if c == '|'
				res << 'cid00600'
			elsif c == '.'
				res << 'cid00601'
			elsif '２３４５６７８９'.index(c)
				res << 'cid0060' + ('２３４５６７８９'.index(c)+2).to_s
			elsif $kanacids.has_key?(c)
				res << $kanacids[c]
			elsif '⑴⑵⑶⑷⑸⑹⑺⑻⑼'.index(c)
				res << 'cid0061' + ('⑴⑵⑶⑷⑸⑹⑺⑻⑼'.index(c)+1).to_s
			elsif $kanasmallgns.has_key?(c)
				res << $kanasmallgns[c] + '-kata.vert'
			elsif $kanagns.has_key?(c)
				res << $kanagns[c] + '-kata.fwid'
				#res << 'uni' + c.ord.to_s(16).upcase
			elsif $kanacids.has_key?(c)
				res << $kanacids[c]
			else
				res << '?' + c.ord.to_s(16)
				puts "Error #{@kana} - #{c}"
			end
		}

		res.join('+')
	end
end

$sy = Hash.new(0)

f = File.open('logical_syllables.txt', 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	$sy[s] = Sound.new(s, 'logical')
}
f.close

max_moe_cnt = 0
max_ttl_cnt = 0

ff = File.open('readings_table.txt', 'w:utf-8')
f = File.open('readings_merged.txt', 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	
	c, moe, ith = s.split(/\t/)

	u = c.ord.to_s(16).upcase
	t = moe != '' ? 'A' : ''
	t += 'B' if ith != nil && ith != ''
	ff.print "#{c}\t#{u}\t#{t}"
	
	moe_cnt = 0
	ith_cnt = 0

	moe.gsub(/[」　？]/, '').split(/, /).each { |tl|
		next if tl == ''

		gn = tl_to_gn(tl)
		ff.print "\t" + gn
		if !$sy.has_key?(gn)
			$sy[gn] = Sound.new(gn, 'reading')
			puts "Add external reading #{tl} (#{gn})" if !$sy[gn].light
		end
		$sy[gn].cnt += 1
		moe_cnt += 1
	}
	ith.gsub(/[」　？]/, '').split(/, /).each { |tl|
		next if tl == ''

		gn = tl_to_gn(tl)
		ff.print "\t" + gn
		$sy[gn] = Sound.new(gn, 'extent') if !$sy.has_key?(gn)
		$sy[gn].cnt += 1

		ith_cnt += 1
	} if ith
	ff.puts

	#puts c, moe_cnt  if moe_cnt > max_moe_cnt
	max_moe_cnt = moe_cnt if moe_cnt > max_moe_cnt
	max_ttl_cnt = moe_cnt+ith_cnt if moe_cnt+ith_cnt > max_ttl_cnt
}
f.close

puts max_moe_cnt, max_ttl_cnt

f = File.open('linked_sounds.txt', 'r:utf-8')
f.each { |s|
	s.chomp!
	next if s == ''
	
	c, tl, gn = s.split(/\t/)
	gnx = tl_to_gn(tl)
	puts "Error #{gn} != #{gnx} at #{tl}" if gn != gnx

	if !$sy.has_key?(gn)
		$sy[gn] = Sound.new(gn, 'linked')
		puts "Add external linked reading #{tl} (#{gn})"
	end
	$sy[gn].cnt += 1

	ff.puts "#{c}\t-\tX\t#{gn}"
}
f.close
ff.close

f = File.open('taigi_readings.txt', 'w:utf-8')
$sy.sort_by{|gn, v| gn}.each {|gn, v|
	f.puts "#{gn}\t#{v.type}\t#{v.cnt}\t#{v.tl}\t#{v.poj}\t#{v.bpm}\t#{v.kana}"
}
f.close

ff = File.open('glist_tl.txt', 'w:utf-8')
$sy.sort_by{|gn, v| gn}.each {|gn, v|
	ff.puts v.roman_to_gnlist(v.tl) + "=#{gn}-tl"
}
ff.close

ff = File.open('glist_poj.txt', 'w:utf-8')
$sy.sort_by{|gn, v| gn}.each {|gn, v|
	ff.puts v.roman_to_gnlist(v.poj) + "=#{gn}-poj"
}
ff.close

ff = File.open('glist_bpm.txt', 'w:utf-8')
$sy.sort_by{|gn, v| gn}.each {|gn, v|
	ff.puts v.bpm_to_gnlist + "=#{gn}-hi"
}
ff.close

ff = File.open('glist_kana.txt', 'w:utf-8')
$sy.sort_by{|gn, v| gn}.each {|gn, v|
	ff.puts v.kana_to_gnlist + "=#{gn}-kn"
}
ff.close
