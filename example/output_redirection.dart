/// A simple example showcasing how to do output redirection
library example.exec;

import 'package:dscript_exec/dscript_exec.dart';

main() async {
  await (exec('cat', ['example/names.csv']) |
              exec('cut', ['-d', "','", '-f', '1']) >
          new Uri(path: 'example/dest.csv'))
      .run();
}
