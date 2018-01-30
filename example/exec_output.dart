/// A simple example showcasing how to execute a command using [exec] and get its
/// output
library example.exec;

import 'package:dscript_exec/dscript_exec.dart';

main() async {
  final String out = await exec('cat', ['example/names.csv']).runGetOutput();
  print(out);

  await exec('cat', ['example/names.csv']).runGetOutput(onFinish: print);
}
