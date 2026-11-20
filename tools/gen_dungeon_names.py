#!/usr/bin/env python3
"""
Leatrix Maps (Temucraft): the names of the old dungeons and raids that have dungeon maps, in every 3.3.5 game
language, written to Leatrix_Maps/Leatrix_Maps_DungeonNames.lua.

The 3.3.5 GetInstanceInfo() gives no instance map ID, only the instance name in the language of the game. With
these names Leatrix Maps finds the dungeon you are in on any game language (deDE, frFR, esES, ruRU, zhCN, ...),
and shows the dungeon names in that language.

What it reads, for each language: Map.dbc (the instance name, what GetInstanceInfo() gives) and AreaTable.dbc
(the zone name, what GetRealZoneText() gives inside the instance), from that language's game files
(the newest patch-<locale>-N.MPQ that has them).

Usage:
  gen_dungeon_names.py --dbc <folder> [--addon <repo folder, default: this script's repo>]

The folder holds one subfolder per language with its Map.dbc and AreaTable.dbc, such as deDE/Map.dbc and
deDE/AreaTable.dbc. enUS (or enGB, which has the same names) is needed.
"""
import argparse, os, struct

# Instance map IDs with dungeon maps in Leatrix_Maps_Dungeons.lua (the previewList there)
INSTANCES = [389, 36, 43, 33, 34, 48, 90, 47, 189, 129, 70, 209, 349, 109, 230, 229, 409, 469, 429, 289, 329,
             309, 249, 509, 531, 533]
# AreaTable rows on these maps that are not the dungeon itself (The Great Sea, an unused cove)
SKIP_AREAS = {207, 208}
LOCALES = ["enUS", "deDE", "esES", "esMX", "frFR", "koKR", "ruRU", "zhCN", "zhTW"]


def read_dbc(path):
    data = open(path, "rb").read()
    magic, count, fields, size, strsize = struct.unpack_from("<4s4I", data)
    if magic != b"WDBC":
        raise SystemExit(path + " is not a DBC file")
    strings = 20 + count * size
    rows = [struct.unpack_from("<%dI" % fields, data, 20 + i * size) for i in range(count)]

    def text(offset):
        end = data.index(b"\0", strings + offset)
        return data[strings + offset:end].decode("utf-8")
    return rows, text


def first_name(row, start, text):
    # A game language's DBC has its name in one of the 16 name columns
    for i in range(16):
        if row[start + i]:
            return text(row[start + i])
    return ""


def read_locale(folder):
    names, zones = {}, {}
    rows, text = read_dbc(os.path.join(folder, "Map.dbc"))
    for row in rows:  # ID, Directory, InstanceType, Flags, PVP, MapName_lang[16], ...
        if row[0] in INSTANCES:
            names[row[0]] = first_name(row, 5, text)
    rows, text = read_dbc(os.path.join(folder, "AreaTable.dbc"))
    for row in sorted(rows):  # ID, ContinentID, ParentAreaID, ..., AreaName_lang[16] at 11
        if row[1] in INSTANCES and row[2] == 0 and row[0] not in SKIP_AREAS:
            name = first_name(row, 11, text)
            if name and name != names.get(row[1]):
                zones.setdefault(row[1], []).append(name)
    return names, zones


def lua(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser()
    ap.add_argument("--dbc", required=True)
    ap.add_argument("--addon", default=os.path.dirname(here))
    a = ap.parse_args()
    found = {}
    for loc in LOCALES + ["enGB"]:
        folder = os.path.join(a.dbc, loc)
        if os.path.isfile(os.path.join(folder, "Map.dbc")) and os.path.isfile(os.path.join(folder, "AreaTable.dbc")):
            found["enUS" if loc == "enGB" and "enUS" not in found else loc] = read_locale(folder)
    if "enUS" not in found:
        raise SystemExit("enUS (or enGB) Map.dbc and AreaTable.dbc are needed")
    out = [
        "-- Leatrix Maps (Temucraft): names of the old dungeons and raids in every 3.3.5 game language.",
        "-- Made by tools/gen_dungeon_names.py from Map.dbc and AreaTable.dbc of each game language. Do not change by hand.",
        "-- [instance map ID] = {map = {[locale] = instance name (GetInstanceInfo)}, zone = {[locale] = {zone names (GetRealZoneText)}}}",
        "",
        "local void, Leatrix_Maps = ...",
        "",
        "Leatrix_Maps.DungeonNames = {",
    ]
    locs = [l for l in LOCALES if l in found]
    for iid in INSTANCES:
        out.append("\t[%d] = {" % iid)
        out.append("\t\tmap = {" + ", ".join("%s = %s" % (l, lua(found[l][0][iid])) for l in locs if found[l][0].get(iid)) + "},")
        zl = [(l, found[l][1][iid]) for l in locs if found[l][1].get(iid)]
        if zl:
            out.append("\t\tzone = {" + ", ".join("%s = {%s}" % (l, ", ".join(lua(z) for z in zs)) for l, zs in zl) + "},")
        out.append("\t},")
    out.append("}")
    path = os.path.join(a.addon, "Leatrix_Maps", "Leatrix_Maps_DungeonNames.lua")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out) + "\n")
    print("Wrote %s (%d instances, languages: %s)" % (path, len(INSTANCES), ", ".join(locs)))


if __name__ == "__main__":
    main()
