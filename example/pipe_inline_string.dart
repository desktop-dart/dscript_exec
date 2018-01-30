import 'dart:async';
import 'dart:convert';
import 'package:dscript_exec/dscript_exec.dart';

main() async {
  await exec('cat', ['example/names.csv'])
      .pipeInlineString((Stream<String> stream) => stream
          .transform(const LineSplitter())
          .map((s) => s.split(',')[1] + '\r\n'))
      .runGetOutput(onFinish: print);
}
