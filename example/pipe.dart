/// A simple example showcasing how to use pipes
library example.exec;

import 'package:dscript_exec/dscript_exec.dart';

Future<void> main() async {
  await exec('cat', ['example/names.csv'])
      .pipe(exec('cut', ['-d', ',', '-f', '1']))
      .stdout()
      .then(print);
}
