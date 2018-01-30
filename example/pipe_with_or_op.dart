/// A simple example showcasing how to use pipes with `|` operator
library example.exec;

import 'package:dscript_exec/dscript_exec.dart';

main() async {
  await (exec('cat', ['example/names.csv']) |
          exec('cut', ['-d', "','", '-f', '1']))
      .runGetOutput(onFinish: print);
}
