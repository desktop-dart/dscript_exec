part of dscript.exec;

abstract class RunnerMixin {
  Future<Process> run();

  Future<String> runGetOutput({FutureOr onFinish(String output)}) async {
    final Process process = await run();
    final String ret = await process.stdout.transform(UTF8.decoder).join();
    if (onFinish != null) await onFinish(ret);
    return ret;
  }

  Future<Stream<List<int>>> runGetStdout(
      {FutureOr onFinish(Stream<List<int>> output)}) async {
    final Process process = await run();
    if (onFinish != null) await onFinish(process.stdout);
    return process.stdout;
  }

  Future<List<List<int>>> runGetByteList(
      {FutureOr onFinish(List<List<int>> output)}) async {
    final Process process = await run();
    final List<List<int>> ret = await process.stdout.toList();
    if (onFinish != null) await onFinish(ret);
    return ret;
  }

  Future<Stream<String>> runGetStringStream(
      {FutureOr onFinish(Stream<String> output)}) async {
    final Process process = await run();
    final Stream<String> ret = process.stdout.transform(UTF8.decoder);
    if (onFinish != null) await onFinish(ret);
    return ret;
  }

  Future<List<String>> runGetStringList(
      {FutureOr onFinish(List<String> output)}) async {
    final Process process = await run();
    final List<String> ret =
        await process.stdout.transform(UTF8.decoder).toList();
    if (onFinish != null) await onFinish(ret);
    return ret;
  }

  Future<List<String>> runGetLines(
      {FutureOr onFinish(List<String> output)}) async {
    final Process process = await run();
    final List<String> ret = await process.stdout
        .transform(UTF8.decoder)
        .transform(_splitter)
        .toList();
    if (onFinish != null) await onFinish(ret);
    return ret;
  }
}

const LineSplitter _splitter = const LineSplitter();
