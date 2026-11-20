#!/usr/bin/env python3
"""
Leatrix Maps (Temucraft): zone levels and map icons for the zones Leatrix Maps doesn't know, from the Temucraft world
database, written to Leatrix_Maps/Leatrix_Maps_TemucraftData.lua.

What it makes:
  - zone level ranges for our new zones (from the creatures spawned there: low and high end of the levels of the
    creatures you fight; AreaTable.dbc exploration level when a zone has no creatures and that DBC is there)
  - icons: entrances of our new instances (areatrigger + areatrigger_teleport into an instance map that is in
    map_dbc or above the 3.3.5 map IDs), flight masters, spirit healers and portals (spawns), for our new zones; in the zones Leatrix Maps already has, only the entrances of
    our new instances (when Leatrix Maps has no instance icon close by)

Zones are WorldMapArea.dbc rows. On 3.3.5 GetCurrentMapAreaID() is the WorldMapArea ID + 1, which is what Leatrix
Maps keys its icons by. Map coordinates: x = (locLeft - worldY) / (locLeft - locRight),
y = (locTop - worldX) / (locTop - locBottom).

Optional DBCs in the --dbc folder (used when there): FactionTemplate.dbc (flight master side), Map.dbc (instance
names and dungeon or raid), AreaTable.dbc (zone names), TaxiNodes.dbc (flight point names), AreaTrigger.dbc (where
the instance entrances are, for triggers the areatrigger table doesn't have; without either, the corpse spot of
the map from map_dbc or Map.dbc is used, which is next to the entrance). The world database
tables map_dbc, taxinodes_dbc and factiontemplate_dbc are used too when they have rows.

Usage:
  gen_ltm_data.py --db <world database> --dbc <folder with our WorldMapArea.dbc> [--mysql "mysql -uroot -p..."]
                  [--addon <repo folder, default: this script's repo>]
"""
import argparse, os, re, shlex, struct, subprocess
from collections import defaultdict

STOCK_LAST_MAP = 724  # the highest map ID of the 3.3.5a client (The Ruby Sanctum)
NEAR = 3.0            # percent of the map: a new icon this close to one of the same kind in Leatrix Maps is a copy

# creatures that don't count for zone levels
SKIP_TYPES = (8, 11, 12, 13)               # critter, totem, non-combat pet, gas cloud
SKIP_UNIT_FLAGS = 0x2 | 0x100 | 0x200 | 0x2000000  # not attackable, immune to players, immune to NPCs, not selectable


def query(mysql, db, q):
    out = subprocess.run(shlex.split(mysql) + ['-N', '-B', db, '-e', q], check=True, capture_output=True,
                         text=True).stdout
    return [line.split('\t') for line in out.splitlines() if line]


def has_rows(mysql, db, table):
    if not query(mysql, db, "SHOW TABLES LIKE '%s'" % table):
        return False
    return int(query(mysql, db, 'SELECT COUNT(*) FROM `%s`' % table)[0][0]) > 0


def read_dbc(path):
    """Rows of a WDBC file as lists of uint32, and a function that reads a string at an offset."""
    if not os.path.isfile(path):
        return None, None
    b = open(path, 'rb').read()
    magic, n, f, size, ss = struct.unpack('<4s4I', b[:20])
    strings = b[20 + n * size:]
    rows = [list(struct.unpack_from('<%dI' % f, b, 20 + i * size)) for i in range(n)]

    def text(off):
        end = strings.find(b'\0', off)
        return strings[off:end if end >= 0 else len(strings)].decode('utf-8', 'replace')
    return rows, text


def as_float(u):
    return struct.unpack('<f', struct.pack('<I', u))[0]


def world_map_areas(path):
    rows, text = read_dbc(path)
    out = []
    for r in rows or []:
        wid, mapid, area, name_off = r[0], r[1], r[2], r[3]
        left, right, top, bottom = (as_float(v) for v in r[4:8])
        if area and left != right and top != bottom:
            out.append({'id': wid, 'map': mapid, 'area': area, 'file': text(name_off),
                        'left': left, 'right': right, 'top': top, 'bottom': bottom})
    return out


def split_camel(s):
    """'TwilightHighlands' -> 'Twilight Highlands' (zone name when there is no AreaTable.dbc)"""
    s = re.sub(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|(?<=[A-Za-z])(?=\d)', ' ', s)
    s = re.sub(r'(?<=[a-z]{3})(of|the)(?= |$)', r' \1', s)  # 'Valleyof' -> 'Valley of'
    return s.replace(' Of ', ' of ').replace(' The ', ' the ')


def leatrix_known(addon):
    """Map area IDs Leatrix Maps already knows, its icons {id: [(kind, x, y)]} and zone levels {id: (low, high)}."""
    known = set()
    main = open(os.path.join(addon, 'Leatrix_Maps', 'Leatrix_Maps.lua'), encoding='utf-8').read()
    block = main[main.index('local zoneNameToMapID = {'):]
    block = block[:block.index('\n\t}')]
    known |= {int(v) for v in re.findall(r'=\s*(\d+)\s*,', block)}
    names = dict((n, int(v)) for n, v in re.findall(r'\["([^"]+)"\]\s*=\s*(\d+)\s*,', block))
    ranges = {}
    lv = main[main.index('local zoneData = {'):]
    lv = lv[:lv.index('\n\t\t\t}')]
    for n, lo, hi in re.findall(r'\["([^"]+)"\]\s*=\s*\{\s*(\d+)\s*,\s*(\d+)', lv):
        if n in names and int(lo) > 0:
            ranges[names[n]] = (int(lo), int(hi))
    icons = defaultdict(list)
    cur = None
    for line in open(os.path.join(addon, 'Leatrix_Maps', 'Leatrix_Maps_Icons.lua'), encoding='utf-8'):
        m = re.search(r'\[(\d+)\]\s*=\s*\{\s*$', line)
        if m:
            cur = int(m.group(1))
            known.add(cur)
            continue
        m = re.match(r'\s*\{"(\w+)",\s*([\d.]+),\s*([\d.]+)', line)
        if m and cur is not None:
            icons[cur].append((kind_group(m.group(1)), float(m.group(2)), float(m.group(3))))
    return known, icons, ranges


def kind_group(pin_type):
    if pin_type in ('Dungeon', 'Raid', 'Dunraid'):
        return 'instance'
    for p in ('Flight', 'Portal', 'Travel'):
        if pin_type.startswith(p):
            return p.lower()
    return pin_type.lower()


def lua_str(s):
    return '"%s"' % s.replace('\\', '\\\\').replace('"', '\\"')


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--db', required=True)
    ap.add_argument('--dbc', required=True, help='folder with WorldMapArea.dbc (ours, with the new zones)')
    ap.add_argument('--mysql', default='mysql')
    ap.add_argument('--addon', default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    a = ap.parse_args()
    db, my = a.db, a.mysql

    known, leatrix_icons, leatrix_levels = leatrix_known(a.addon)
    wma = world_map_areas(os.path.join(a.dbc, 'WorldMapArea.dbc'))
    by_area, by_map = defaultdict(list), defaultdict(list)
    for z in wma:
        z['key'] = z['id'] + 1  # GetCurrentMapAreaID()
        z['new'] = z['key'] not in known
        by_area[(z['map'], z['area'])].append(z)
        by_map[z['map']].append(z)

    # zone names: AreaTable.dbc, else the map file name split into words
    area_rows, area_text = read_dbc(os.path.join(a.dbc, 'AreaTable.dbc'))
    area_name, area_level = {}, {}
    for r in area_rows or []:
        area_name[r[0]] = area_text(r[11])
        area_level[r[0]] = r[10]
    if has_rows(my, db, 'areatable_dbc'):
        for aid, lvl, name in query(my, db, 'SELECT ID, ExplorationLevel, AreaName_Lang_enUS FROM areatable_dbc'):
            if name:
                area_name[int(aid)] = name
            area_level[int(aid)] = int(lvl)
    for z in wma:
        z['name'] = area_name.get(z['area']) or split_camel(z['file'])

    def zone_for(mapid, zone, x, y):
        def inside(z):
            return z['right'] <= y <= z['left'] and z['bottom'] <= x <= z['top']
        for z in by_area.get((mapid, zone), []):
            if inside(z):
                return z
        # no zone in the row: of the zone boxes on that map holding the spot (they overlap), the one where it is
        # closest to the middle
        best = None
        for z in by_map.get(mapid, []):
            if inside(z):
                off = max(abs((z['left'] - y) / (z['left'] - z['right']) - 0.5),
                          abs((z['top'] - x) / (z['top'] - z['bottom']) - 0.5))
                if best is None or off < best[0]:
                    best = (off, z)
        return best[1] if best else None

    def stock_zones_at(mapid, x, y):
        """Zones Leatrix Maps has whose box holds the spot (boxes overlap, so a spot in a new zone's box can be in
        an old zone)"""
        return [z for z in by_map.get(mapid, []) if not z['new'] and z['right'] <= y <= z['left']
                and z['bottom'] <= x <= z['top']]

    def within(inner, outer):
        return (outer['right'] <= inner['right'] and inner['left'] <= outer['left']
                and outer['bottom'] <= inner['bottom'] and inner['top'] <= outer['top'])

    def coords(z, x, y):
        return (round(100 * (z['left'] - y) / (z['left'] - z['right']), 1),
                round(100 * (z['top'] - x) / (z['top'] - z['bottom']), 1))

    idcol = 'id1' if query(my, db, "SHOW COLUMNS FROM creature LIKE 'id1'") else 'id'

    # ---- sides: FactionTemplate.dbc, else factiontemplate_dbc
    side_of = {}
    frows, _ = read_dbc(os.path.join(a.dbc, 'FactionTemplate.dbc'))
    ft = [(r[0], r[3], r[4], r[5]) for r in frows or []]
    if not ft and has_rows(my, db, 'factiontemplate_dbc'):
        ft = [tuple(int(v) for v in r) for r in
              query(my, db, 'SELECT ID, FactionGroup, FriendGroup, EnemyGroup FROM factiontemplate_dbc')]
    for fid, group, friend, enemy in ft:
        ally = (group | friend) & 2 and not enemy & 2
        horde = (group | friend) & 4 and not enemy & 4
        side_of[fid] = 'A' if ally and not horde else 'H' if horde and not ally else 'N'

    friendly = sorted(f for f, v in side_of.items() if v != 'N')
    not_friendly = ' AND t.faction NOT IN (%s)' % ','.join(map(str, friendly)) if friendly else ''

    # ---- instance maps: name, dungeon or raid, level range
    instances = {int(r[0]) for r in query(my, db, 'SELECT map FROM instance_template')}
    map_name, map_type, custom_maps = {}, {}, set()
    mrows, mtext = read_dbc(os.path.join(a.dbc, 'Map.dbc'))
    corpse = {}  # where you come back to life outside an instance: next to its entrance
    for r in mrows or []:
        map_name[r[0]] = mtext(r[5])
        map_type[r[0]] = r[2]
        if len(r) > 61 and r[59] != 0xFFFFFFFF:
            corpse[r[0]] = (r[59], as_float(r[60]), as_float(r[61]))
    if has_rows(my, db, 'map_dbc'):
        for mid, kind, name, cmap, cx, cy in query(my, db, 'SELECT ID, InstanceType, MapName_Lang_enUS, CorpseMapID, '
                                                   'CorpseX, CorpseY FROM map_dbc'):
            mid = int(mid)
            custom_maps.add(mid)
            map_type[mid] = int(kind)
            if name:
                map_name[mid] = name
            if int(cmap) >= 0:
                corpse[mid] = (int(cmap), float(cx), float(cy))
    if has_rows(my, db, 'mapdifficulty_dbc'):
        for mid, players in query(my, db, 'SELECT MapID, MAX(MaxPlayers) FROM mapdifficulty_dbc GROUP BY MapID'):
            map_type.setdefault(int(mid), 2 if int(players) > 5 else 1)
    custom_maps |= {m for m in instances if m > STOCK_LAST_MAP}

    # where the area triggers are: the areatrigger table, else AreaTrigger.dbc
    trigger_at = {}
    arows, _ = read_dbc(os.path.join(a.dbc, 'AreaTrigger.dbc'))
    for r in arows or []:
        trigger_at[r[0]] = (r[1], as_float(r[2]), as_float(r[3]))
    if query(my, db, "SHOW TABLES LIKE 'areatrigger'"):
        for tid, mid, x, y in query(my, db, 'SELECT entry, map, x, y FROM areatrigger'):
            trigger_at[int(tid)] = (int(mid), float(x), float(y))
    teleports = []
    for tid, target, name in query(my, db, 'SELECT ID, target_map, Name FROM areatrigger_teleport'):
        if int(tid) in trigger_at:
            teleports.append(trigger_at[int(tid)] + (target, name))
    # our instances with no trigger we can place: the corpse spot from map_dbc or Map.dbc
    placed = {int(t[3]) for t in teleports}
    for mid in sorted(custom_maps - placed):
        if mid in corpse and corpse[mid][1:] != (0.0, 0.0):
            teleports.append(corpse[mid] + (str(mid), ''))
    for _, _, _, target, name in teleports:
        target = int(target)
        if target not in map_name and name:
            map_name[target] = re.sub(r'\s*[-(]?\s*(entrance|enter|entry)\)?\s*$', '', name, flags=re.I).strip()

    # creature levels per instance map: the bosses and elites set the range
    inst_levels = {}
    for mid, lo, hi in query(my, db,
                             'SELECT c.map, MIN(t.minlevel), MAX(t.maxlevel) FROM creature c '
                             'JOIN creature_template t ON t.entry = c.%s WHERE t.rank IN (1, 2, 3) '
                             'AND t.type NOT IN %s AND t.maxlevel < 100 AND t.npcflag = 0%s '
                             'GROUP BY c.map' % (idcol, str(SKIP_TYPES), not_friendly)):
        inst_levels[int(mid)] = (int(lo), int(hi))

    # ---- zone levels from the creatures you fight
    spawns = query(my, db,
                   'SELECT c.map, c.zoneId, c.position_x, c.position_y, t.minlevel, t.maxlevel FROM creature c '
                   'JOIN creature_template t ON t.entry = c.%s WHERE t.type NOT IN %s AND t.npcflag = 0 '
                   'AND (t.unit_flags & %d) = 0 AND t.rank IN (0, 1) AND t.maxlevel BETWEEN 2 AND 99%s'
                   % (idcol, str(SKIP_TYPES), SKIP_UNIT_FLAGS, not_friendly))
    zone_lv = defaultdict(list)
    for mapid, zone, x, y, lo, hi in spawns:
        z = zone_for(int(mapid), int(zone or 0), float(x), float(y))
        if z and z['new'] and int(mapid) not in instances:
            lo, hi = int(lo), int(hi)
            # in an old zone's box too and in its level range: it is that zone's creature (unless the new zone is a
            # part of that old zone, like the starting areas)
            if any(z2['key'] in leatrix_levels and leatrix_levels[z2['key']][0] - 3 <= lo
                   and hi <= leatrix_levels[z2['key']][1] + 3 and not within(z, z2)
                   for z2 in stock_zones_at(int(mapid), float(x), float(y))):
                continue
            zone_lv[z['key']].append((lo, hi))
    levels = {}
    for z in wma:
        if not z['new'] or z['map'] in instances:
            continue
        lv = zone_lv.get(z['key'])
        if lv and len(lv) >= 5:
            los = sorted(v[0] for v in lv)
            his = sorted(v[1] for v in lv)
            lo, hi = los[len(los) // 10], his[len(his) - 1 - len(his) // 10]  # without the lowest and highest 10%
            levels[z['key']] = (z['name'], lo, max(lo, hi))
        elif area_level.get(z['area']):
            levels[z['key']] = (z['name'], area_level[z['area']], area_level[z['area']])

    # ---- flight point names: TaxiNodes.dbc, else taxinodes_dbc
    taxi = []
    trows, ttext = read_dbc(os.path.join(a.dbc, 'TaxiNodes.dbc'))
    for r in trows or []:
        taxi.append((r[1], as_float(r[2]), as_float(r[3]), ttext(r[5])))
    if not taxi and has_rows(my, db, 'taxinodes_dbc'):
        taxi = [(int(m), float(x), float(y), n) for m, x, y, n in
                query(my, db, 'SELECT ContinentID, X, Y, Name_Lang_enUS FROM taxinodes_dbc')]

    def taxi_name(mapid, x, y):
        best = None
        for m, tx, ty, name in taxi:
            if m == mapid and name:
                d = (tx - x) ** 2 + (ty - y) ** 2
                if d < 60 ** 2 and (best is None or d < best[0]):
                    best = (d, name)
        return best[1] if best else None

    # ---- icons
    icons = defaultdict(list)

    def add(z, kind, x, y, entry):
        """Adds an icon unless Leatrix Maps (or this run) already has one of its kind close by. In the zones Leatrix
        Maps has, only entrances to our new instances are added."""
        if not z['new'] and kind != 'instance':
            return
        if not z['new'] and any(k == kind and (ix - x) ** 2 + (iy - y) ** 2 < NEAR ** 2
                                for k, ix, iy in leatrix_icons.get(z['key'], [])):
            return
        if any(e[0] == kind and (e[1] - x) ** 2 + (e[2] - y) ** 2 < 1.0 for e in icons[z['key']]):
            return
        icons[z['key']].append((kind, x, y, entry))

    # area triggers have no zone: take the zone of the nearest spawn (WorldMapArea boxes overlap)
    grid = defaultdict(list)
    for mapid, zone, x, y in query(my, db, 'SELECT map, zoneId, position_x, position_y FROM creature WHERE zoneId > 0 '
                                   'UNION ALL SELECT map, zoneId, position_x, position_y FROM gameobject '
                                   'WHERE zoneId > 0'):
        x, y = float(x), float(y)
        grid[(int(mapid), int(x // 100), int(y // 100))].append((x, y, int(zone)))

    def spawn_zone(mapid, x, y):
        best = None
        for gx in range(int(x // 100) - 1, int(x // 100) + 2):
            for gy in range(int(y // 100) - 1, int(y // 100) + 2):
                for sx, sy, zone in grid.get((mapid, gx, gy), ()):
                    d = (sx - x) ** 2 + (sy - y) ** 2
                    if best is None or d < best[0]:
                        best = (d, zone)
        return best[1] if best else 0

    entrances = 0
    for src, x, y, target, _ in teleports:
        src, target = int(src), int(target)
        if target not in instances or src in instances:
            continue
        z = zone_for(src, spawn_zone(src, float(x), float(y)), float(x), float(y))
        if not z or target not in custom_maps:
            continue  # Leatrix Maps has the entrances of the 3.3.5 instances
        kind = 'Raid' if map_type.get(target) == 2 else 'Dungeon'
        lo, hi = inst_levels.get(target, (None, None))
        px, py = coords(z, float(x), float(y))
        name = map_name.get(target) or 'Map %d' % target
        entry = '{"%s", %s, %s, %s, "%s", "%s"%s}' % (kind, px, py, lua_str(name), kind, kind,
                                                     ', %d, %d' % (lo, hi) if lo else '')
        add(z, 'instance', px, py, entry)
        entrances += 1

    def spawn_icons(sql, make):
        n = 0
        for row in query(my, db, sql):
            mapid, x, y = int(row[0]), float(row[1]), float(row[2])
            if mapid in instances:
                continue
            z = zone_for(mapid, int(row[3] or 0), x, y)
            if not z:
                continue
            px, py = coords(z, x, y)
            kind, entry = make(z, mapid, x, y, px, py, row[4:])
            if z['new'] and any(k == kind and (ix - ox) ** 2 + (iy - oy) ** 2 < NEAR ** 2
                                for z2 in stock_zones_at(mapid, x, y) for ox, oy in [coords(z2, x, y)]
                                for k, ix, iy in leatrix_icons.get(z2['key'], [])):
                continue  # Leatrix Maps shows it in the old zone it overlaps
            add(z, kind, px, py, entry)
            n += 1
        return n

    def flight(z, mapid, x, y, px, py, rest):
        name, faction = rest
        side = side_of.get(int(faction), 'N')
        label = taxi_name(mapid, x, y) or name
        if z['name'] not in label:
            label += ', ' + z['name']
        tex = {'A': 'TaxiNode_Alliance', 'H': 'TaxiNode_Horde'}.get(side, 'TaxiNode_Neutral')
        return 'flight', '{"Flight%s", %s, %s, %s, nil, "%s"}' % (side, px, py, lua_str(label), tex)

    def spirit(z, mapid, x, y, px, py, rest):
        return 'spirit', '{"Spirit", %s, %s, "Spirit Healer", nil, "Spirit"}' % (px, py)

    def portal(z, mapid, x, y, px, py, rest):
        name, faction = rest
        side = side_of.get(int(faction), 'N')
        tex = {'A': 'TaxiNode_Continent_Alliance', 'H': 'TaxiNode_Continent_Horde'}.get(side,
                                                                                         'TaxiNode_Continent_Neutral')
        return 'portal', '{"Portal%s", %s, %s, %s, "Portal", "%s"}' % (side, px, py, lua_str(name), tex)

    base = ('SELECT c.map, c.position_x, c.position_y, c.zoneId, t.name, t.faction FROM creature c '
            'JOIN creature_template t ON t.entry = c.%s WHERE (t.npcflag & %%d) <> 0' % idcol)
    flights = spawn_icons(base % 8192, flight)
    spirits = spawn_icons(base % 16384, spirit)
    portals = spawn_icons("SELECT g.map, g.position_x, g.position_y, g.zoneId, t.name, COALESCE(d.faction, 0) "
                          "FROM gameobject g JOIN gameobject_template t ON t.entry = g.id "
                          "LEFT JOIN gameobject_template_addon d ON d.entry = t.entry "
                          "WHERE t.type IN (22, 27) AND t.name LIKE 'Portal to %'", portal)

    out = os.path.join(a.addon, 'Leatrix_Maps', 'Leatrix_Maps_TemucraftData.lua')
    with open(out, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('-- Made by tools/gen_ltm_data.py from the Temucraft world database and WorldMapArea.dbc. Do not edit.\n')
        fh.write('-- Keys are GetCurrentMapAreaID() (the WorldMapArea ID + 1). Leatrix_Maps_Temucraft.lua adds this to Leatrix Maps.\n\n')
        fh.write('local void, Leatrix_Maps = ...\n\n')
        fh.write('-- Zone levels: [map area ID] = {"English zone name", lowest level, highest level}\n')
        fh.write('Leatrix_Maps["TemucraftZones"] = {\n')
        for key in sorted(levels):
            name, lo, hi = levels[key]
            fh.write('\t[%d] = {%s, %d, %d},\n' % (key, lua_str(name), lo, hi))
        fh.write('}\n\n')
        fh.write('-- Icons, in the Leatrix_Maps_Icons.lua format: {type, x, y, name, subtitle, texture, low level, high level}\n')
        fh.write('Leatrix_Maps["TemucraftIcons"] = {\n')
        names = {z['key']: z['name'] for z in wma}
        for key in sorted(icons):
            fh.write('\t--[[%s]] [%d] = {\n' % (names.get(key, '?').replace(']]', ''), key))
            for _, _, _, entry in sorted(icons[key], key=lambda e: (e[0], e[1], e[2])):
                fh.write('\t\t%s,\n' % entry)
            fh.write('\t},\n')
        fh.write('}\n')

    new = sum(1 for z in wma if z['new'])
    print('zones in WorldMapArea.dbc: %d, new to Leatrix Maps: %d, with levels: %d' % (len(wma), new, len(levels)))
    print('icons: %d in %d zones (entrances seen %d, flight masters %d, spirit healers %d, portals %d)' % (
        sum(len(v) for v in icons.values()), len(icons), entrances, flights, spirits, portals))


if __name__ == '__main__':
    main()
