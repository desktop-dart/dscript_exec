import 'dart:io';
import 'dart:convert';
import 'package:dscript_exec/dscript_exec.dart';

main() async {
  await exec('cat', ['example/names.csv'])
      .pipe(exec('cut', ['-d', "','", '-f', '1']))
      .run(onFinish: (Process p) async {
    print(await p.stdout.transform(UTF8.decoder).join());
    print(await p.stderr.transform(UTF8.decoder).join());
  });
}
