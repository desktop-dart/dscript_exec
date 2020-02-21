/// A simple example showcasing how to do input redirection
library example.exec;

import 'package:dscript_exec/dscript_exec.dart';

Future<void> main() async {
  await (exec('cut', ['-d', ',', '-f', '1']) <
          '''
John,Smith,34,London
Arthur,Evans,21,Newport
George,Jones,32,Truro
          ''')
      .stdout()
      .then(print);
}
