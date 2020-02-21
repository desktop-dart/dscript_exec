/// A simple example showcasing how to execute a command using [exec]
library example.exec;

import 'package:dscript_exec/dscript_exec.dart';

Future<void> main() async {
  await exec('rm', ['example/dest.csv']).run();
}
