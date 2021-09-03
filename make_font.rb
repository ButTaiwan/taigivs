# encoding: utf-8

toolpath = Dir.exists?('d:\fontworks') ? 'd:\fontworks' : 'd:\fontprj'
$otfccdump = toolpath + '\otfcc\otfccdump.exe'
$otfccbuild = toolpath + '\otfcc\otfccbuild.exe'
$ttx = toolpath + '\FDK\Tools\win\ttx'
$emptyfont = 'emptyfont.json'

$font_vendor = 'But Ko'
$font_url = 'https://github.com/ButTaiwan/taigivs'

require 'json'
require 'set'

$upm = 1000

$fullwidth = 1500
$ruby_top_offy = 952		# 880+94=974 (ruby: 94/312)
$ruby_top_ascender = 1280	# 880+406=1286
$ruby_top_height = 1400		# 1000+406=1406
$ruby_right_offx = 1000

#$ruby_top_offx = 250		# when no ruby_right

$ivs = 0xe01e0 #65024

$rubys = nil
$readings = nil
$combo_readings = nil
$hanzi = Set.new

def read_reading_data
	cnt = 0

	$rubys = []
	f = File.open('./readings/taigi_readings.txt', 'r:utf-8')
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s[0] == '#'
		tmp = s.split(/\t/)
		$rubys << tmp[0]
	}
	f.close
	
	$readings = {}
	$combo_readings = {}
	f = File.open('readings/readings_table.txt', 'r:utf-8')
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s[0] == '#'
		tmp = s.split(/\t/)
		if tmp[2] != 'X'
			$readings[tmp[0]] = tmp[3..-1]
			$hanzi << tmp[0].ord.to_s(16).upcase
			cnt = tmp.size-3 if tmp.size-3 > cnt
		else 
			$combo_readings[tmp[0]] = tmp[3..-1]
		end
	}
	f.close
	cnt
end

#$svs = 65024


def align_pos contours, dir
	min = 9999
	max = -9999
	axis = (dir == 'L' || dir == 'R') ? 'x' : 'y'
	contours.each { |path|
		path.each { |node|
			max = node[axis] if node[axis] > max
			min = node[axis] if node[axis] < min
		}
	}
	
	off = 0
	off = 1100 - max if dir == 'L'
	off =  400 - min if dir == 'R'
	off =  680 - max if dir == 'B'
	off =  100 - min if dir == 'T'
	contours.each_with_index { |path, i|
		path.each_with_index { |node, j|
			contours[i][j][axis] += off
		}
	}
	contours
end

def gen_rotate_glyph sg, advWidth, offx
	h = sg['advanceWidth']
	paths = []
	if sg.has_key?('contours')
		sg['contours'].each { |sp|
			path = []
			sp.each { |sn|
				path << {'x' => sn['y'] + 120 + offx, 'y' => h-sn['x'], 'on' => sn['on']}
			}
			paths << path
		}
	end

	return {
		'advanceWidth' => advWidth,
		'advanceHeight' => h,
		'verticalOrigin' => h,
		'contours' => paths
	}
end

def shift_path contours, dir, off
	return nil if contours == nil
	contours.each_with_index { |path, i|
		path.each_with_index { |node, j|
			contours[i][j][dir] += off
		}
	}
	contours
end

def read_font fnt, input, ruby_top, ruby_right
	$charlist = {}
	$charcfg = {}
	#$unignmap = {}
	$allglyphs = Set.new

	# 加入基本ASCII字元
	(0x20..0x7e).each { |i| $charlist[sprintf('%04x', i).upcase] = false}

	# 讀取所有非漢字字元
	f = File.open('symbols.txt', 'r:utf-8')
	f.each { |s|
		s.chomp!
		s.gsub!(/\#.*$/, '')
		next if s == ''
		next if s[0] == '#'
		
		u, cfg = s.split(/\t/)
		u.chomp!
		$charlist[u] = false
		$charcfg[u] = ',' + (cfg || '') + ','
	}
	f.close

	$hanzi.each { |u|
		$charlist[u] = false
		$charcfg[u] = ',,'
	}


	
	# 先清點算過來源字型檔的vert對應
	src_verts = {}
	input['GSUB']['lookups'].each { |lkn, lkup|
		next unless lkn =~ /_vert_/
		
		lkup['subtables'].each { |lktb|
			lktb.each { |n1, n2|
				src_verts[n1] = n2
			}
		}
		break
	}

	# 讀取salt對應（源X系列預設為比例寬字，但注音字型還是改回對應的全形字比較好）
	src_salts = {}
	input['GSUB']['lookups'].each { |lkn, lkup|
		next unless lkn =~ /_salt_/
		
		lkup['subtables'].each { |lktb|
			lktb.each { |n1, n2|
				src_salts[n1] = n2
			}
		}
		break
	}

	#advWidth = ruby_right ? 1500 : 1000

	# 開始複製來源字符
	$charlist.keys.each { |uniHex|
		uniDec = uniHex.to_i(16).to_s
		next unless input['cmap'].has_key?(uniDec)
		
		c = uniDec.to_i.chr(Encoding::UTF_8)
		fgn = input['cmap'][uniDec]
		fgn = src_salts[fgn] if src_salts.has_key?(fgn)
		g = input['glyf'][fgn]
		#g['contours'] = shift_y(g['contours'], offy) if offy != 0 && g.has_key?('contours')
		#g['instructions'] = []

		if $readings.has_key?(c)					# 有注音定義的漢字
			g['advanceWidth'] = ruby_right ? $fullwidth : $upm
			g['advanceHeight'] = $upm
			#g['contours'] = shift_path(g['contours'], 'x', $ruby_top_offx) if !ruby_right
			gn = 'uni' + uniHex + '.ss00'
			fnt['glyf'][gn] = g
			$order_han << gn
			fnt['cmap_uvs'][uniDec + ' ' + ($ivs).to_s] = gn
		#elsif (漢字) 
		elsif g['advanceWidth'] == 1024 || g['advanceWidth'] == 1000			# 全形符號
			gn = fgn
			g['advanceWidth'] = ruby_right ? $fullwidth : $upm
			g['advanceHeight'] = $upm if g['advanceHeight'] >= 1000
			#g['contours'] = shift_path(g['contours'], 'x', $ruby_top_offx) if !ruby_right
			g['contours'] = align_pos(g['contours'], $1) if ruby_right && $charcfg[uniHex] =~ /,([LRTB]),/
			fnt['glyf'][gn] = g
			fnt['cmap'][uniDec] = gn
			$order_sym << gn
		else									# 半形符號等
			gn = fgn
			fnt['glyf'][gn] = g
			fnt['cmap'][uniDec] = gn
			$order_sym << gn
			
			if g['advanceWidth'] < 1000 && g['advanceWidth'] != 600 # && g.has_key?('contours') #(bpmftones)
				#gv = gen_rotate_glyph(g, ruby_right ? $fullwidth : $upm, ruby_right ? 0 : $ruby_top_offx)
				gv = gen_rotate_glyph(g, ruby_right ? $fullwidth : $upm, 0)
				gvn = gn+'.vrt2'
				fnt['glyf'][gvn] = gv
				$vrt2s[gn] = gvn
			end
		end
		$charlist[uniHex] = gn

		$allglyphs << gn

		# 從來源字型讀取直排(vert)用字符
		next unless $charcfg[uniHex] =~ /,vert,/
		next unless src_verts.has_key?(fgn)
		
		fvgn = src_verts[fgn]
		gv = input['glyf'][fvgn]
		gvn = gn + '.vert'
		gv['advanceWidth'] = ruby_right ? $fullwidth : $upm
		gv['advanceHeight'] = $upm
		fnt['glyf'][gvn] = gv
		$order_sym << gvn
		$verts[gn] = gvn
		$allglyphs << gvn
	}

	# 台羅、白話字特例: 複製所有源X系列自製 glyphXXX 字符
	input['glyf'].each { |gn, g|
		next if gn !~ /^glyph[34]\d\d$/
	
		if g['advanceWidth'] == 1024 || g['advanceWidth'] == 1000			# 全形符號
			g['advanceWidth'] = ruby_right ? $fullwidth : $upm
			g['advanceHeight'] = $upm if g['advanceHeight'] >= 1000
			# verticalOrigin
			fnt['glyf'][gn] = g
			$order_sym << gn
		else									# 半形符號等
			fnt['glyf'][gn] = g
			$order_sym << gn
			
			if g['advanceWidth'] < 1000 && g['advanceWidth'] != 600 && g.has_key?('contours') #(bpmftones)
				#gv = gen_rotate_glyph(g,ruby_right ? $fullwidth : $upm, ruby_right ? 0 : $ruby_top_offx)
				gv = gen_rotate_glyph(g,ruby_right ? $fullwidth : $upm, 0)
				gvn = gn+'.vrt2'
				fnt['glyf'][gvn] = gv
				$vrt2s[gn] = gvn
			end
		end
		$allglyphs << gn
	}

	# 取得原始的ccmp
	src_ccmps = []
	input['GSUB']['lookups'].each { |lkn, lkup|
		next unless lkn =~ /_ccmp_/
		next if lkup['type'] != 'gsub_ligature'
		
		lkup['subtables'].each { |lktb|
			next if !lktb.has_key?('substitutions')
			lktb['substitutions'].each { |subrow| src_ccmps << subrow }
		}
		break
	}

	return src_verts, src_ccmps
end

def copy_ruby_glyphs(fnt, rubytype)
	data = File.read("rubyfonts/ruby_#{rubytype}.json")
	input = JSON.parse(data)

	$rubys.each { |gn|
		srcgn = input['glyf'].has_key?(gn + rubytype) ? gn + rubytype : gn + '-' + rubytype
		targn = rubytype + '_' + gn

		g = input['glyf'][srcgn]
		fnt['glyf'][targn] = g
		$order_ruby << targn
	}
end

def cal_latin_shift fnt, ruby_right
	lshifts = {}

	$order_ruby.each { |gn|
		lshifts[gn] = 0
		gw = fnt['glyf'][gn]['advanceWidth'].to_i

		if gw < $upm
			lshifts[gn] = ($upm-gw) / 2
		elsif !ruby_right
			lshifts[gn] = 0
		elsif gw < $fullwidth-120
			lshifts[gn] = 60
		else
			lshifts[gn] = ($fullwidth-gw) /2
		end
	}

	lshifts
end

def cal_han_shift fnt
	hshifts = {}
	$order_ruby.each { |gn|
		hshifts[gn] = 0
		gw = fnt['glyf'][gn]['advanceWidth'].to_i
		hshifts[gn] = gw < $upm ? 0 : (gw-$upm)/2
	}

	hshifts
end

def create_rubied_glyphs fnt, ruby_top, ruby_right
	puts "Now create rubied glyphs..."

	#shifts = ruby_top && ruby_right ? cal_latin_shift(fnt) : nil
	lshifts = ruby_top ? cal_latin_shift(fnt, ruby_right) : nil
	hshifts = ruby_top && (!ruby_right) ? cal_han_shift(fnt) : nil
	
	$charlist.each { |uniHex, gn|
		next unless gn

		uniDec = uniHex.to_i(16).to_s
		c = uniHex.to_i(16).chr(Encoding::UTF_8)
		next unless $readings.has_key?(c)
		
		$readings[c].each_with_index { |readgn, i|
			hangn = 'uni'+uniHex+'.ss00'
			gly = {
				advanceWidth: ruby_right ? $fullwidth : [$upm, fnt['glyf'][ruby_top+'_'+readgn]['advanceWidth']].max,
				advanceHeight: ruby_top ? $ruby_top_height : $upm, 
				verticalOrigin: fnt['glyf'][hangn]['verticalOrigin'] + (ruby_top ? ($ruby_top_height - $upm) : 0),
				references: [{ glyph: hangn, x: (hshifts ? hshifts[ruby_top+'_'+readgn] : 0), y: 0 }]
			}
			gly[:references] << { glyph: ruby_top + '_' + readgn, x: 0 + (lshifts ? lshifts[ruby_top+'_'+readgn] : 0), y: $ruby_top_offy} if ruby_top
			gly[:references] << { glyph: ruby_right + '_' + readgn, x: $ruby_right_offx, y: 0} if ruby_right
		
			gn = 'uni'+uniHex
			if i == 0
				fnt['cmap'][uniDec] = gn
			else
				gn += '.ss0' + i.to_s
				fnt['cmap_uvs'][uniDec + ' ' + ($ivs + i).to_s] = gn
				#$sslist[i]['uni' + uniHex] = gn
			end
			fnt['glyf'][gn] = gly
			$order_han << gn
		}
	}
end

def generate_gsub(fnt, src_verts, src_ccmps)
	
	aalt = {}
	#aalts_single = {}

	$charlist.each { |uniHex, gn|
		next unless gn
		
		if $charcfg[uniHex] =~ /v:([0-9A-F]+)/
			$verts[gn] = $charlist[$1] if $charlist.has_key?($1)
		end
	}
	
	vert = $verts.merge($vrt2s)
	src_verts.each { |k, v|
		next unless $allglyphs === k
		next unless $allglyphs === v
		next if $verts.has_key?(k)
		vert[k] = v
	}
	vert.each { |k, v| aalt[k] = v }	
	
	ccmps = []
	src_ccmps.each { |cmp|
		allexists = true
		allexists = false unless $allglyphs === cmp['to']
		cmp['from'].each { |fgn| allexists = false unless $allglyphs === fgn }
		ccmps << cmp if allexists
	}

	fnt['GSUB'] = {
		'languages' => {
			'DFLT_DFLT' => { 'features' => ['aalt_00000', 'ccmp_00001', 'vert_00002', 'vrt2_00003'] }
		},
		'features' => {
			'aalt_00000' => ['lookup_aalt_0'],
			'ccmp_00001' => ['lookup_ccmp_1'],
			'vert_00002' => ['lookup_vert_2'],
			'vrt2_00003' => ['lookup_vrt2_3']
		},
		'lookups' => {
			'lookup_aalt_0' => { 'type' => 'gsub_single', 'flags' => {}, 'subtables' => [ aalt ] },
			'lookup_ccmp_1' => { 'type' => 'gsub_ligature', 'flags' => {}, 'subtables' => [ { 'substitutions' => ccmps } ] },
			'lookup_vert_2' => { 'type' => 'gsub_single', 'flags' => {}, 'subtables' => [ vert ] },
			'lookup_vrt2_3' => { 'type' => 'gsub_single', 'flags' => {}, 'subtables' => [ vert ] }
		}
	}
end

def set_font_table fnt, input, c_family, c_weight, e_family, e_weight, version, ruby_top, ruby_right
	$nmap = Hash.new { nil }
	input['name'].each { |ne| $nmap[ne['nameID']] = ne['nameString'] if ne['platformID'] == 3 }

	weight = $nmap[17] || $nmap[2] || 'R'
	weight = 'R' if weight == 'Regular'
	license = $nmap[13] || nil
	license_url = $nmap[14] || nil

	psname = e_family.gsub(/\s/, '') + '-' + e_weight + '-' + weight
	identifier = (version+';'+psname).gsub(/\s/, '')
	
	fnt['head']['fontRevision'] = version.to_f
	fnt['name'] = [
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1028, 'nameID':  1, 'nameString': c_family + ' ' + c_weight + ' ' + weight },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1028, 'nameID':  2, 'nameString': e_weight + ' ' + weight },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1028, 'nameID':  4, 'nameString': c_family + ' ' + c_weight + ' ' + weight },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1028, 'nameID': 16, 'nameString': c_family },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1028, 'nameID': 17, 'nameString': c_weight + ' ' + weight },

		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  1, 'nameString': e_family + ' ' + e_weight + ' ' + weight },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  2, 'nameString': e_weight + ' ' + weight },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  3, 'nameString': identifier },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  4, 'nameString': e_family + ' ' + e_weight + ' ' + weight },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  5, 'nameString': 'Version ' + version },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  6, 'nameString': psname },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID':  8, 'nameString': $font_vendor },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID': 11, 'nameString': $font_url },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID': 16, 'nameString': e_family },
		{ 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID': 17, 'nameString': e_weight + ' ' + weight },

		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  1, 'nameString': e_family + ' ' + e_weight + ' ' + weight },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  2, 'nameString': e_weight + ' ' + weight },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  3, 'nameString': identifier },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  4, 'nameString': e_family + ' ' + e_weight + ' ' + weight },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  5, 'nameString': 'Version ' + version },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  6, 'nameString': psname },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID':  8, 'nameString': $font_vendor },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID': 11, 'nameString': $font_url },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID': 16, 'nameString': e_family },
		{ 'platformID' => 1, 'encodingID' => 0, 'languageID' => 0, 'nameID': 17, 'nameString': e_weight + ' ' + weight }
	]

	fnt['name'] << { 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID': 13, 'nameString': license } if license && license != ''
	fnt['name'] << { 'platformID' => 3, 'encodingID' => 1, 'languageID' => 1033, 'nameID': 14, 'nameString': license_url } if license_url && license_url != ''

	fnt['cmap_uvs'] = {} unless fnt.has_key?('cmap_uvs')
	fnt['OS_2']['ulCodePageRange1'] = { 'big5' => true }
	fnt['OS_2']['fsType'] = 0
	fnt['OS_2']['panose'][2] = input['OS_2']['panose'][2]
	fnt['OS_2']['usWeightClass'] = input['OS_2']['usWeightClass']

	ascender = ruby_top ? $ruby_top_ascender : 1000
	fnt['OS_2']['xAvgCharWidth'] = ruby_right ? $fullwidth : $upm
	fnt['OS_2']['sTypoAscender'] = ascender
	fnt['OS_2']['usWinAscent'] = ascender
	fnt['hhea']['ascender'] = ascender
	#fnt['hhea']['descender'] = ascender

	fnt['vhea']['ascent'] = (ruby_right ? $fullwidth : $upm) / 2
	fnt['vhea']['descent'] = -(ruby_right ? $fullwidth : $upm) / 2

	return psname
end

def make_font c_family, c_weight, e_family, e_weight, version, ruby_top = nil, ruby_right = nil
	fnt = JSON.parse(File.read($emptyfont))

	$order_sym = []
	$order_ruby = []
	$order_han = []

	$verts = {}
	$vrt2s = {}

	puts "Now copy glyphs from source font..."
	input = JSON.parse(File.read('tmp/src_font.json'))

	psname = set_font_table fnt, input, c_family, c_weight, e_family, e_weight, version, ruby_top, ruby_right
	src_verts, src_ccmps = read_font fnt, input, ruby_top, ruby_right

	copy_ruby_glyphs(fnt, ruby_top) if ruby_top
	copy_ruby_glyphs(fnt, ruby_right) if ruby_right
	create_rubied_glyphs(fnt, ruby_top, ruby_right)
	generate_gsub(fnt, src_verts, src_ccmps)

	fnt['glyph_order'] = ['.notdef'] + $order_sym + $order_han.sort + $order_ruby

	f = File.open('tmp/output.json', 'w:utf-8')
	f.puts JSON.pretty_generate(fnt)
	f.close

	puts "Build TrueType font... (pre)"
	system("#{$otfccbuild} tmp/output.json -o tmp/otfbuild.ttf")

	puts "Fix Cmap..."
	system("#{$ttx} -t cmap -o tmp/otfbuild_cmap.ttx tmp/otfbuild.ttf")
	system("#{$ttx} -m tmp/otfbuild.ttf -o outputs/#{psname}.ttf tmp/otfbuild_cmap.ttx")
end

def make_font_group src_font, c_fname, e_fname, version, combineHI = false, combineKN = false
	puts "Now dump font to JSON..."
	system("#{$otfccdump} --pretty srcfonts/#{src_font} -o tmp/src_font.json")

	make_font(c_fname, '台羅', e_fname, 'TL', version, 'tl', nil)
	make_font(c_fname, '白話字', e_fname, 'POJ', version, 'poj', nil)
	make_font(c_fname, '方音', e_fname, 'HI', version, nil, 'hi')
	make_font(c_fname, '假名', e_fname, 'KN', version, nil, 'kn')
	make_font(c_fname, '台羅方音', e_fname, 'TLHI', version, 'tl', 'hi') if combineHI
	make_font(c_fname, '白話字方音', e_fname, 'POJHI', version, 'poj', 'hi') if combineHI
	make_font(c_fname, '台羅假名', e_fname, 'TLKN', version, 'tl', 'kn') if combineKN
	make_font(c_fname, '白話字假名', e_fname, 'POJKN', version, 'poj', 'kn') if combineKN
end

$max_reading_cnt = read_reading_data

version = '0.930'
make_font_group 'ZihiKaiStd.ttf', '字咍標楷', 'Taigi KaiStd', version, true, true
make_font_group 'GenRyuMinTW-R.ttf', '字咍源流明體', 'Taigi GenRyuM', version, true, true
make_font_group 'GenRyuMinTW-B.ttf', '字咍源流明體', 'Taigi GenRyuM', version, true, false
make_font_group 'GenRyuMinTW-H.ttf', '字咍源流明體', 'Taigi GenRyuM', version, false, false
make_font_group 'GenWanMinTW-L.ttf', '字咍源雲明體', 'Taigi GenWanM', version, true, true
make_font_group 'GenSekiGothicTW-R.ttf', '字咍源石黑體', 'Taigi GenSekiG', version, true, true
make_font_group 'GenSekiGothicTW-B.ttf', '字咍源石黑體', 'Taigi GenSekiG', version, true, false
make_font_group 'GenSekiGothicTW-L.ttf', '字咍源石黑體', 'Taigi GenSekiG', version, false, false
make_font_group 'GenSekiGothicTW-H.ttf', '字咍源石黑體', 'Taigi GenSekiG', version, false, false
make_font_group 'GenSenRoundedTW-R.ttf', '字咍源泉圓體', 'Taigi GenSenR', version, true, true
make_font_group 'GenSenRoundedTW-L.ttf', '字咍源泉圓體', 'Taigi GenSenR', version, false, false
make_font_group 'GenSenRoundedTW-M.ttf', '字咍源泉圓體', 'Taigi GenSenR', version, true, false
