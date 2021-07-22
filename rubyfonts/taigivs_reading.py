
# 取得最大寬高度

maxv = maxh = maxa = 0
minv = minh = mind = 9999
maxg = ming = None

for g in Glyphs.font.glyphs:
	if g.name.find('-tl') > 0:
		if g.layers[0].width > maxv:
			maxv = g.layers[0].width
			maxg = g.name
		if g.layers[0].width < minv:
			minv = g.layers[0].width
			ming = g.name
			
		b = g.layers[0].bounds
		if b.size.height > maxh:
			maxh = b.size.height
		if b.size.height < minh:
			minh = b.size.height
		if b.origin.y < mind:
			mind = b.origin.y
		if b.origin.y+b.size.height > maxa:
			maxa = b.origin.y+b.size.height

print maxv, maxg
print minv, ming
print maxh, minh
print maxa, mind


# 將羅馬字正確縮小到adv width並置中對齊，解開所有組件

#3211, 1000
# * 0.31

#3720*1014 A780 D234

ADVW = 1500
SCALE = 0.4

for lyr in Glyphs.font.selectedLayers:
	if lyr.parent.name.find('-tl') < 0 and lyr.parent.name.find('-poj') < 0: continue
	if lyr.parent.color != 3: continue
	
	w_src = lyr.width
	w_tar = int(w_src*SCALE)
	p_left = int((ADVW-w_tar)/2)
	
#	print w_tar, p_left
	
	for comp in lyr.components:
		x_src = comp.position.x
		x_tar = int(x_src*SCALE+p_left)
		#print x_tar
		comp.automaticAlignment = False
		comp.scale = SCALE
		comp.position = (x_tar, comp.position.y)

	while len(lyr.components) > 0:
		lyr.components[0].decompose()

	lyr.width = ADVW
	lyr.parent.color = 6
	lyr.parent.export = True


# 方音或假名

import re

UPM = 1000
TOP = 880
RATIO = 0.33
ADVW = 500
TONE_X = 310
DES = UPM-TOP

KANATONE_Y = 266

def is_kana_tone(comp):
	gn = comp.componentName
	return re.match('cid0060[2-9]|cid0061[1-9]', gn)

def is_bpm_tone(comp):
	gn = comp.componentName
	return re.match('.+tone.+|^final', gn)


for lyr in Glyphs.font.selectedLayers:
	if lyr.parent.name.find('-hi') < 0 and lyr.parent.name.find('-kn') < 0: continue
	if lyr.parent.color != 3: continue
	
	h = 0
	hlist = [None] * len(lyr.components)
	for i in range(len(lyr.components)):
		comp = lyr.components[i]
		if is_kana_tone(comp): continue
		if is_bpm_tone(comp): continue
		ch = comp.component.layers[0].vertWidth
		if ch > UPM: ch = UPM
		ch = int(ch*RATIO*0.95)
		hlist[i] = ch
		h += ch
		#print comp.component.layers[0].vertOrigin
		
	top = TOP - int((UPM-h)/2 - DES*RATIO)
	if h > 1000 or top > 880:
		print lyr.parent.name, h, top
	
	for i in range(len(lyr.components)):
		comp = lyr.components[i]
		comp.automaticAlignment = False
		if is_kana_tone(comp):
			comp.scale = RATIO
			comp.position = (TONE_X, KANATONE_Y)
		elif is_bpm_tone(comp):
			comp.scale = RATIO
			comp.position = (TONE_X, top + offy)
		else:
			offy = 0
			if comp.component.layers[0].vertOrigin != None:
				#print comp.component.layers[0].vertOrigin
				offy = -int((UPM-comp.component.layers[0].vertOrigin) * RATIO-hlist[i])
			top -= hlist[i]
			comp.scale = RATIO
			comp.position = (0, top + offy)

	while len(lyr.components) > 0:
		lyr.components[0].decompose()
	
	lyr.width = ADVW
	lyr.parent.color = 6
	lyr.parent.export = True
