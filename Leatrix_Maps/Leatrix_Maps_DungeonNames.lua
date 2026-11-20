-- Leatrix Maps (Temucraft): names of the old dungeons and raids in every 3.3.5 game language.
-- Made by tools/gen_dungeon_names.py from Map.dbc and AreaTable.dbc of each game language. Do not change by hand.
-- [instance map ID] = {map = {[locale] = instance name (GetInstanceInfo)}, zone = {[locale] = {zone names (GetRealZoneText)}}}

local void, Leatrix_Maps = ...

Leatrix_Maps.DungeonNames = {
	[389] = {
		map = {enUS = "Ragefire Chasm", deDE = "Der Flammenschlund", esES = "Sima Ígnea", esMX = "Sima Ígnea", frFR = "Gouffre de Ragefeu", koKR = "성난불길 협곡", ruRU = "Огненная пропасть", zhCN = "怒焰裂谷", zhTW = "怒焰裂谷"},
	},
	[36] = {
		map = {enUS = "Deadmines", deDE = "Todesminen", esES = "Minas de la Muerte", esMX = "Minas de la Muerte", frFR = "Mortemines", koKR = "죽음의 폐광", ruRU = "Мертвые копи", zhCN = "死亡矿井", zhTW = "死亡礦坑"},
		zone = {enUS = {"The Deadmines"}, deDE = {"Die Todesminen"}, esES = {"Las Minas de la Muerte"}, esMX = {"Las Minas de la Muerte"}, frFR = {"Les Mortemines"}},
	},
	[43] = {
		map = {enUS = "Wailing Caverns", deDE = "Höhlen des Wehklagens", esES = "Cuevas de los Lamentos", esMX = "Cuevas de los Lamentos", frFR = "Cavernes des Lamentations", koKR = "통곡의 동굴", ruRU = "Пещеры Стенаний", zhCN = "哀嚎洞穴", zhTW = "哀嚎洞穴"},
		zone = {deDE = {"Die Höhlen des Wehklagens"}, frFR = {"Cavernes des lamentations"}},
	},
	[33] = {
		map = {enUS = "Shadowfang Keep", deDE = "Burg Schattenfang", esES = "Castillo de Colmillo Oscuro", esMX = "Castillo de Colmillo Oscuro", frFR = "Donjon d'Ombrecroc", koKR = "그림자송곳니 성채", ruRU = "Крепость Темного Клыка", zhCN = "影牙城堡", zhTW = "影牙城堡"},
	},
	[34] = {
		map = {enUS = "Stormwind Stockade", deDE = "Verlies von Sturmwind", esES = "Mazmorras de Ventormenta", esMX = "Mazmorras de Ventormenta", frFR = "Prison de Hurlevent", koKR = "스톰윈드 지하감옥", ruRU = "Тюрьма Штормграда", zhCN = "暴风城监狱", zhTW = "暴風城監獄"},
		zone = {enUS = {"The Stockade"}, deDE = {"Das Verlies"}, esES = {"Las Mazmorras"}, esMX = {"Las Mazmorras"}, frFR = {"La Prison"}, ruRU = {"Тюрьма"}, zhCN = {"监狱"}, zhTW = {"監獄"}},
	},
	[48] = {
		map = {enUS = "Blackfathom Deeps", deDE = "Tiefschwarze Grotte", esES = "Cavernas de Brazanegra", esMX = "Cavernas de Brazanegra", frFR = "Profondeurs de Brassenoire", koKR = "검은심연의 나락", ruRU = "Непроглядная Пучина", zhCN = "黑暗深渊", zhTW = "黑暗深淵"},
	},
	[90] = {
		map = {enUS = "Gnomeregan", deDE = "Gnomeregan", esES = "Gnomeregan", esMX = "Gnomeregan", frFR = "Gnomeregan", koKR = "놈리건", ruRU = "Гномреган", zhCN = "诺莫瑞根", zhTW = "諾姆瑞根"},
	},
	[47] = {
		map = {enUS = "Razorfen Kraul", deDE = "Kral der Klingenhauer", esES = "Horado Rajacieno", esMX = "Horado Rajacieno", frFR = "Kraal de Tranchebauge", koKR = "가시덩굴 우리", ruRU = "Лабиринты Иглошкурых", zhCN = "剃刀沼泽", zhTW = "剃刀沼澤"},
	},
	[189] = {
		map = {enUS = "Scarlet Monastery", deDE = "Scharlachrotes Kloster", esES = "Monasterio Escarlata", esMX = "Monasterio Escarlata", frFR = "Monastère écarlate", koKR = "붉은십자군 수도원", ruRU = "Монастырь Алого ордена", zhCN = "血色修道院", zhTW = "血色修道院"},
		zone = {deDE = {"Das Scharlachrote Kloster"}},
	},
	[129] = {
		map = {enUS = "Razorfen Downs", deDE = "Hügel der Klingenhauer", esES = "Zahúrda Rajacieno", esMX = "Zahúrda Rajacieno", frFR = "Souilles de Tranchebauge", koKR = "가시덩굴 구릉", ruRU = "Курганы Иглошкурых", zhCN = "剃刀高地", zhTW = "剃刀高地"},
	},
	[70] = {
		map = {enUS = "Uldaman", deDE = "Uldaman", esES = "Uldaman", esMX = "Uldaman", frFR = "Uldaman", koKR = "울다만", ruRU = "Ульдаман", zhCN = "奥达曼", zhTW = "奧達曼"},
	},
	[209] = {
		map = {enUS = "Zul'Farrak", deDE = "Zul'Farrak", esES = "Zul'Farrak", esMX = "Zul'Farrak", frFR = "Zul'Farrak", koKR = "줄파락", ruRU = "Зул'Фаррак", zhCN = "祖尔法拉克", zhTW = "祖爾法拉克"},
	},
	[349] = {
		map = {enUS = "Maraudon", deDE = "Maraudon", esES = "Maraudon", esMX = "Maraudon", frFR = "Maraudon", koKR = "마라우돈", ruRU = "Мародон", zhCN = "玛拉顿", zhTW = "瑪拉頓"},
	},
	[109] = {
		map = {enUS = "Sunken Temple", deDE = "Versunkener Tempel", esES = "Templo Sumergido", esMX = "Templo Sumergido", frFR = "Temple englouti", koKR = "가라앉은 사원", ruRU = "Затонувший храм", zhCN = "沉没的神庙", zhTW = "沉沒的神廟"},
		zone = {enUS = {"The Temple of Atal'Hakkar"}, deDE = {"Der Tempel von Atal'Hakkar"}, esES = {"El Templo de Atal'Hakkar"}, esMX = {"El Templo de Atal'Hakkar"}, frFR = {"Le temple d'Atal'Hakkar"}, koKR = {"아탈학카르 신전"}, ruRU = {"Храм Атал'Хаккара"}, zhCN = {"阿塔哈卡神庙"}, zhTW = {"阿塔哈卡神廟"}},
	},
	[230] = {
		map = {enUS = "Blackrock Depths", deDE = "Schwarzfelstiefen", esES = "Profundidades de Roca Negra", esMX = "Profundidades de Roca Negra", frFR = "Profondeurs de Rochenoire", koKR = "검은바위 나락", ruRU = "Глубины Черной горы", zhCN = "黑石深渊", zhTW = "黑石深淵"},
	},
	[229] = {
		map = {enUS = "Blackrock Spire", deDE = "Schwarzfelsspitze", esES = "Cumbre de Roca Negra", esMX = "Cumbre de Roca Negra", frFR = "Pic Rochenoire", koKR = "검은바위 첨탑", ruRU = "Пик Черной горы", zhCN = "黑石塔", zhTW = "黑石塔"},
	},
	[409] = {
		map = {enUS = "Molten Core", deDE = "Geschmolzener Kern", esES = "Núcleo de Magma", esMX = "Núcleo de Magma", frFR = "Cœur du Magma", koKR = "화산 심장부", ruRU = "Огненные Недра", zhCN = "熔火之心", zhTW = "熔火之心"},
	},
	[469] = {
		map = {enUS = "Blackwing Lair", deDE = "Pechschwingenhort", esES = "Guarida de Alanegra", esMX = "Guarida de Alanegra", frFR = "Repaire de l'Aile noire", koKR = "검은날개 둥지", ruRU = "Логово Крыла Тьмы", zhCN = "黑翼之巢", zhTW = "黑翼之巢"},
	},
	[429] = {
		map = {enUS = "Dire Maul", deDE = "Düsterbruch", esES = "La Masacre", esMX = "La Masacre", frFR = "Hache-tripes", koKR = "혈투의 전장", ruRU = "Забытый Город", zhCN = "厄运之槌", zhTW = "厄運之槌"},
	},
	[289] = {
		map = {enUS = "Scholomance", deDE = "Scholomance", esES = "Scholomance", esMX = "Scholomance", frFR = "Scholomance", koKR = "스칼로맨스", ruRU = "Некроситет", zhCN = "通灵学院", zhTW = "通靈學院"},
	},
	[329] = {
		map = {enUS = "Stratholme", deDE = "Stratholme", esES = "Stratholme", esMX = "Stratholme", frFR = "Stratholme", koKR = "스트라솔름", ruRU = "Стратхольм", zhCN = "斯坦索姆", zhTW = "斯坦索姆"},
	},
	[309] = {
		map = {enUS = "Zul'Gurub", deDE = "Zul'Gurub", esES = "Zul'Gurub", esMX = "Zul'Gurub", frFR = "Zul'Gurub", koKR = "줄구룹", ruRU = "Зул'Гуруб", zhCN = "祖尔格拉布", zhTW = "祖爾格拉布"},
	},
	[249] = {
		map = {enUS = "Onyxia's Lair", deDE = "Onyxias Hort", esES = "Guarida de Onyxia", esMX = "Guarida de Onyxia", frFR = "Repaire d'Onyxia", koKR = "오닉시아의 둥지", ruRU = "Логово Ониксии", zhCN = "奥妮克希亚的巢穴", zhTW = "奧妮克希亞的巢穴"},
	},
	[509] = {
		map = {enUS = "Ruins of Ahn'Qiraj", deDE = "Ruinen von Ahn'Qiraj", esES = "Ruinas de Ahn'Qiraj", esMX = "Ruinas de Ahn'Qiraj", frFR = "Ruines d'Ahn'Qiraj", koKR = "안퀴라즈 폐허", ruRU = "Руины Ан'Киража", zhCN = "安其拉废墟", zhTW = "安其拉廢墟"},
	},
	[531] = {
		map = {enUS = "Ahn'Qiraj Temple", deDE = "Tempel von Ahn'Qiraj", esES = "Templo de Ahn'Qiraj", esMX = "Templo de Ahn'Qiraj", frFR = "Temple d'Ahn'Qiraj", koKR = "안퀴라즈 사원", ruRU = "Храм Ан'Киража", zhCN = "安其拉神殿", zhTW = "安其拉神廟"},
		zone = {enUS = {"Ahn'Qiraj"}, deDE = {"Ahn'Qiraj"}, esES = {"Ahn'Qiraj"}, esMX = {"Ahn'Qiraj"}, frFR = {"Ahn'Qiraj"}, koKR = {"안퀴라즈"}, ruRU = {"Ан'Кираж"}, zhCN = {"安其拉"}, zhTW = {"安其拉"}},
	},
	[533] = {
		map = {enUS = "Naxxramas", deDE = "Naxxramas", esES = "Naxxramas", esMX = "Naxxramas", frFR = "Naxxramas", koKR = "낙스라마스", ruRU = "Наксрамас", zhCN = "纳克萨玛斯", zhTW = "納克薩瑪斯"},
	},
}
