import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:process_run/shell.dart';

const basePath = '';

void main() async {
  var list = await getImagesList();
  handle(list);
}

// 1 遍历 assets/images 下的所有图片文件
Future<List<FileSystemEntity>> getImagesList() async {
  var imagesDir = Directory('$basePath/assets/images');
  return imagesDir.listSync(recursive: true);
}

// 2 保存一份原始名字
handle(List<FileSystemEntity> list) {
  list.forEach((FileSystemEntity file) {
    String md5Str = getMd5(file.path);
    String originKey = file.path.replaceAll('$basePath/', '');
    String hashKey = originKey.replaceAll('.', '-$md5Str.');
    String hashPath = file.path.replaceAll(originKey, hashKey);
    print('originKey: $originKey, haskKey: $hashKey, pashPath: $hashPath');
    // 重命名文件
    //file.rename(hashPath);
    // 在js文件中替换引用的位置
    replaceImageName(originKey, hashKey);
  });
}
// 3 计算每个文件的md5
String getMd5(String path) {
  return md5.convert(File(path).readAsBytesSync()).toString().substring(0, 10);
}
// 4 在所有的js文件中查找替换文件
replaceImageName(String originKey, String hashKey) async {
   var shell = Shell();
   String cmdStr = 'sed -i s/${originKey.replaceAll('/', '\\/')}/${hashKey.replaceAll('/', '\\/')}/g $basePath/main.dart*js';
   print('cmdStr: $cmdStr');
   await shell.run(cmdStr);
}