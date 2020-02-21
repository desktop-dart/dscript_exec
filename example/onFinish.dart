import 'dart:convert';
import 'dart:io';

import 'package:dscript_exec/dscript_exec.dart';

Future<void> main() async {
  await exec('cat', ['example/names.csv'])
      .pipe(exec('cut', ['-d', ',', '-f', '1']))
      .run()
      .then((Process p) async {
    print(await p.stdout.transform(utf8.decoder).join());
    print(await p.stderr.transform(utf8.decoder).join());
  });
}
