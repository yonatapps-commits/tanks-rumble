// Generates placeholder tileset PNG, TSX, and TMX for development.
// Run with: dart run tool/generate_placeholder_assets.dart

import 'dart:io';
import 'dart:typed_data';

void main() {
  generateTilesetPng();
  generateTilesetTsx();
  generateArenaMap();
  print('All placeholder assets generated!');
}

void generateTilesetPng() {
  // 128x32 PNG with 4 colored 32x32 tiles:
  // Tile 1 (GID 1): Sky blue     #87CEEB
  // Tile 2 (GID 2): Grass green  #4CAF50
  // Tile 3 (GID 3): Brown earth  #795548
  // Tile 4 (GID 4): Dark stone   #455A64

  final width = 128;
  final height = 32;
  final tileColors = [
    [0x87, 0xCE, 0xEB], // sky blue
    [0x4C, 0xAF, 0x50], // grass green
    [0x79, 0x55, 0x48], // brown earth
    [0x45, 0x5A, 0x64], // dark stone
  ];

  // Build raw pixel rows (filter byte + RGB for each pixel)
  final rawData = <int>[];
  for (var y = 0; y < height; y++) {
    rawData.add(0); // filter: none
    for (var x = 0; x < width; x++) {
      final tileIndex = x ~/ 32;
      rawData.addAll(tileColors[tileIndex]);
    }
  }

  final compressed = zlib.encode(rawData);

  final png = BytesBuilder();

  // PNG signature
  png.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR chunk
  final ihdr = BytesBuilder();
  ihdr.add(_uint32(width));
  ihdr.add(_uint32(height));
  ihdr.add([8]); // bit depth
  ihdr.add([2]); // color type: RGB
  ihdr.add([0, 0, 0]); // compression, filter, interlace
  _writeChunk(png, 'IHDR', ihdr.toBytes());

  // IDAT chunk
  _writeChunk(png, 'IDAT', Uint8List.fromList(compressed));

  // IEND chunk
  _writeChunk(png, 'IEND', Uint8List(0));

  File('assets/tiles/terrain_tileset.png').writeAsBytesSync(png.toBytes());
  print('  terrain_tileset.png (128x32, 4 tiles)');
}

void generateTilesetTsx() {
  final tsx = '''<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="terrain_tileset" tilewidth="32" tileheight="32" tilecount="4" columns="4">
 <image source="terrain_tileset.png" width="128" height="32"/>
</tileset>
''';
  File('assets/tiles/terrain_tileset.tsx').writeAsStringSync(tsx);
  print('  terrain_tileset.tsx');
}

void generateArenaMap() {
  // Map: 60 tiles wide x 34 tiles tall = 1920x1088 pixels
  // Tile GIDs: 0=empty(sky), 1=sky, 2=grass, 3=earth, 4=stone
  final mapWidth = 60;
  final mapHeight = 34;
  final groundRow = 26; // rows 26-33 = ground

  final buffer = StringBuffer();

  for (var y = 0; y < mapHeight; y++) {
    for (var x = 0; x < mapWidth; x++) {
      var gid = 0; // empty = transparent (sky blue background shows)

      // Ground
      if (y >= groundRow) {
        gid = 2; // grass
      }
      // Mountain (trapezoid shape, narrowing toward top)
      else if (y >= 18 && y < groundRow) {
        final rowFromTop = y - 18; // 0-7
        final shrink = rowFromTop ~/ 2;
        final mLeft = 27 + shrink;
        final mRight = 33 - shrink;
        if (x >= mLeft && x <= mRight) {
          gid = 3; // earth
        }
      }

      buffer.write(gid);
      if (x < mapWidth - 1 || y < mapHeight - 1) buffer.write(',');
    }
    buffer.writeln();
  }

  // Spawn Y = top of ground - tank height (48px = ~1.5 tiles)
  final groundY = groundRow * 32;
  final spawnY = groundY - 48;
  // Mountain peak Y
  final peakY = 18 * 32 - 48;

  final tmx = '''<?xml version="1.0" encoding="UTF-8"?>
<map version="1.5" tiledversion="1.7.2" orientation="orthogonal" renderorder="right-down" width="$mapWidth" height="$mapHeight" tilewidth="32" tileheight="32" infinite="0" nextlayerid="4" nextobjectid="10">
 <tileset firstgid="1" source="terrain_tileset.tsx"/>

 <layer id="1" name="terrain" width="$mapWidth" height="$mapHeight">
  <data encoding="csv">
${buffer.toString().trim()}
  </data>
 </layer>

 <objectgroup id="2" name="objects">
  <object id="1" name="spawn_player" type="spawn" x="160" y="$spawnY" width="64" height="48"/>
  <object id="2" name="spawn_enemy" type="spawn" x="${mapWidth * 32 - 224}" y="$spawnY" width="64" height="48"/>
  <object id="3" name="flag_position" type="flag" x="${mapWidth * 32 ~/ 2 - 16}" y="$peakY" width="32" height="48"/>
  <object id="4" name="star_zone" type="star_zone" x="100" y="64" width="${mapWidth * 32 - 200}" height="400"/>
 </objectgroup>

 <objectgroup id="3" name="collision">
  <object id="5" name="ground" type="collision" x="0" y="$groundY" width="${mapWidth * 32}" height="${(mapHeight - groundRow) * 32}"/>
  <object id="6" name="mountain" type="collision" x="${27 * 32}" y="${18 * 32}">
   <polygon points="${(29 - 27) * 32},0 ${(31 - 27 + 1) * 32},0 ${(33 - 27 + 1) * 32},${(groundRow - 18) * 32} 0,${(groundRow - 18) * 32}"/>
  </object>
 </objectgroup>
</map>
''';

  File('assets/tiles/arena_01.tmx').writeAsStringSync(tmx);
  print('  arena_01.tmx (${mapWidth}x$mapHeight tiles)');
}

Uint8List _uint32(int value) {
  return Uint8List(4)
    ..[0] = (value >> 24) & 0xFF
    ..[1] = (value >> 16) & 0xFF
    ..[2] = (value >> 8) & 0xFF
    ..[3] = value & 0xFF;
}

void _writeChunk(BytesBuilder builder, String type, Uint8List data) {
  builder.add(_uint32(data.length));
  final typeBytes = type.codeUnits;
  builder.add(typeBytes);
  builder.add(data);
  // CRC32 over type + data
  final crcData = BytesBuilder();
  crcData.add(typeBytes);
  crcData.add(data);
  builder.add(_uint32(_crc32(crcData.toBytes())));
}

int _crc32(List<int> data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc = crc >> 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
