# encoding: utf-8

toolpath = Dir.exists?('d:\fontworks') ? 'd:\fontworks' : 'd:\fontprj'
$otfccdump = toolpath + '\otfcc\otfccdump.exe'
$otfccbuild = toolpath + '\otfcc\otfccbuild.exe'
#$ttx = toolpath + '\FDK\Tools\win\ttx'
#$bpmfsrc = 'f_bpmfgen.js'

$font_vendor = 'But Ko'
$font_url = 'https://github.com/ButTaiwan/taigivs'

require 'json'
#require 'set'

font_file = 'CabinTLCondensed-Regular.ttf'
tar = 'tl'

list = {
	# 'CabinTLCondensed-Regular.ttf' => 'tl',
	# 'CabinPOJCondensed-Regular.ttf' => 'poj',
	'JostTL-Medium.ttf' => 'tl',
	'JostPOJ-Medium.ttf' => 'poj',
	'GenYoRubyHI-SB.ttf' => 'hi',
	'GenYoRubyKANA-SB.ttf' => 'kn',
}
list.each { |fn, tar|
	puts "Now dump font #{fn}..."
	system("#{$otfccdump} --pretty #{fn} -o ruby_#{tar}.json")
}
