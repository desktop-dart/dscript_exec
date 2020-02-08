part of dscript.exec;

abstract class RunnerMixin {
  Future<Process> run();

  Future<String> stdout() async {
    final process = await run();
    final ret = await process.stdout.transform(utf8.decoder).join();
    return ret;
  }

  Future<int> exitCode() async {
    final process = await run();
    return process.exitCode;
  }

  /*
  Future<Stream<String>> runGetStringStream(
      {FutureOr onFinish(Stream<String> output)}) async {
    final Process process = await run();
    final Stream<String> ret = process.stdout.transform(utf8.decoder);
    if (onFinish != null) await onFinish(ret);
    return ret;
  }

  Future<List<String>> runGetLines(
      {FutureOr onFinish(List<String> output)}) async {
    final Process process = await run();
    final List<String> ret = await process.stdout
        .transform(utf8.decoder)
        .transform(_splitter)
        .toList();
    if (onFinish != null) await onFinish(ret);
    return ret;
  }
  */
}

const LineSplitter _splitter = LineSplitter();
