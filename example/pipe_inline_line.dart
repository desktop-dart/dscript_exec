import 'dart:async';
import 'package:dscript_exec/dscript_exec.dart';

Future<void> main() async {
  await exec('cat', ['example/names.csv'])
      .pipeInlineLine(
          (Stream<String> stream) => stream.map((s) => s.split(',')[1]))
      .stdout()
      .then(print);
}
