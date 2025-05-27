import 'dart:convert';
import 'dart:typed_data';

Uint8List addWavHeader(Uint8List pcmData, int sampleRate, int channels) {
  final byteRate = sampleRate * channels * 2;
  final blockAlign = channels * 2;
  final dataSize = pcmData.length;
  final fileSize = 36 + dataSize;

  final header = BytesBuilder();
  header.add(ascii.encode('RIFF'));
  header.add(_intToBytes(fileSize, 4));
  header.add(ascii.encode('WAVE'));
  header.add(ascii.encode('fmt '));
  header.add(_intToBytes(16, 4)); // Subchunk1Size
  header.add(_intToBytes(1, 2));  // AudioFormat (PCM)
  header.add(_intToBytes(channels, 2));
  header.add(_intToBytes(sampleRate, 4));
  header.add(_intToBytes(byteRate, 4));
  header.add(_intToBytes(blockAlign, 2));
  header.add(_intToBytes(16, 2)); // BitsPerSample
  header.add(ascii.encode('data'));
  header.add(_intToBytes(dataSize, 4));

  return Uint8List.fromList(header.toBytes() + pcmData);
}

List<int> _intToBytes(int value, int byteCount) {
  final bytes = <int>[];
  for (var i = 0; i < byteCount; i++) {
    bytes.add((value >> (8 * i)) & 0xFF);
  }
  return bytes;
}
