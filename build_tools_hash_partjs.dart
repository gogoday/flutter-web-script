import 'dart:io';
import 'package:crypto/crypto.dart';

const basePath = 'build/web';
void main() async {
  File file = File('$basePath/main.dart.js');
  try{
    String content = await file.readAsString();
    // print(content);
    RegExp exp = RegExp(r"deferredPartUris:\[.*\]");
    Iterable<Match> matchs = exp.allMatches(content);

    for (Match m in matchs) {
      String? match = m.group(0);
      String? match2 = '';

      if (match is String) {
        RegExp expJsFile = RegExp(r"main\.dart\.js_\d+\.part\.js");
        Iterable<Match> filesName = expJsFile.allMatches(match);
        for (Match f in filesName) {
          String? jsPartName = f.group(0);
          if (jsPartName is String) {
            var file = File('$basePath/$jsPartName');
            String md5Str = md5.convert(file.readAsBytesSync()).toString().substring(0, 10);
            String newName = jsPartName.replaceFirst('part', 'part-$md5Str');
            file.renameSync('$basePath/$newName');
            match2 = match.replaceFirst(jsPartName, newName);
          }
        }
      }
      // no part file
      if (match2 == '') {
        exit(0);
      }
      print('s/deferredPartUris:.*/$match2,/g');
      exit(0);
    }
  }catch(e){
    print(e);
    exit(1);
  }
}
