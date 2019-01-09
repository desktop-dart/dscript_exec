part of dscript.exec;

class ProcessWithProxyStdout implements Process {
  final Process _internal;

  Stream<List<int>> _stdout;

  ProcessWithProxyStdout(this._internal, this._stdout);

  Future<int> get exitCode => _internal.exitCode;

  Stream<List<int>> get stdout => _stdout;

  Stream<List<int>> get stderr => _internal.stderr;

  IOSink get stdin => _internal.stdin;

  int get pid => _internal.pid;

  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) =>
      _internal.kill(signal);
}

abstract class Op {
  Future<Process> runWith(Process other);
}

class Pipe implements Op {
  final Command cmd;

  Pipe(this.cmd);

  Future<Process> runWith(Process other) async {
    final Process newProcess = await cmd.run();
    await other.stdout.pipe(newProcess.stdin);
    return newProcess;
  }
}

typedef FutureOr<Stream<List<int>>> InlineFunc(Stream<List<int>> stdin);

typedef FutureOr<Stream<String>> InlineStringFunc(Stream<String> stdin);

class InlinePipe implements Op {
  final InlineFunc cmd;

  InlinePipe(this.cmd);

  Future<ProcessWithProxyStdout> runWith(Process other) async =>
      new ProcessWithProxyStdout(other, await cmd(other.stdout));
}

class InlineStringPipe implements Op {
  final InlineStringFunc cmd;

  InlineStringPipe(this.cmd);

  Future<ProcessWithProxyStdout> runWith(Process other) async =>
      new ProcessWithProxyStdout(
          other,
          (await cmd(other.stdout.transform(utf8.decoder)))
              .transform(utf8.encoder));
}

class InlineLinePipe implements Op {
  final InlineStringFunc cmd;

  InlineLinePipe(this.cmd);

  Future<ProcessWithProxyStdout> runWith(Process other) async =>
      new ProcessWithProxyStdout(
          other,
          (await cmd(other.stdout.transform(utf8.decoder).transform(_splitter)))
              .map((s) => s + '\r\n')
              .transform(utf8.encoder));
}

class InputRedirect implements Op {
  final dest;

  InputRedirect(this.dest);

  Future<Process> runWith(Process other) async {
    if (dest is File || dest is Uri) {
      File file;
      if (dest is File) {
        file = dest;
      } else if (dest is Uri) {
        file = new File((dest as Uri).path);
      }
      other.stdin.addStream(file.openRead());
    } else if (dest is List<int>) {
      other.stdin.add(dest);
      await other.stdin.flush();
      await other.stdin.close();
    } else if (dest is Stream<List<int>>) {
      (dest as Stream<List<int>>).pipe(other.stdin);
    } else if (dest is String) {
      other.stdin.write(dest);
      await other.stdin.flush();
      await other.stdin.close();
    }
    return other;
  }
}

class OutputRedirect implements Op {
  final dest;

  OutputRedirect(this.dest);

  Future<Process> runWith(Process other) async {
    if (dest is File || dest is Uri) {
      File file;
      if (dest is File) {
        file = dest;
      } else if (dest is Uri) {
        file = new File((dest as Uri).path);
      }
      final IOSink sink = await file.openWrite();
      other.stdout.listen((List<int> data) => sink.add(data),
          cancelOnError: true, onError: (_) async {
        await sink.flush();
        await sink.close();
      }, onDone: () async {
        await sink.flush();
        await sink.close();
      });
    } else if (dest is StringBuffer) {
      StringBuffer sb = dest;
      other.stdout.listen((List<int> data) => sb.write(utf8.decode(data)),
          cancelOnError: true);
    } else if (dest is List<int>) {
      List<int> list = dest;
      other.stdout
          .listen((List<int> data) => list.addAll(data), cancelOnError: true);
    } else if (dest is StreamConsumer<List<int>>) {
      StreamConsumer<List<int>> stream = dest;
      other.stdout.pipe(stream);
    } else if (dest is StreamConsumer<String>) {
      StreamConsumer<String> stream = dest;
      other.stdout.transform(utf8.decoder).pipe(stream);
    }
    return other;
  }
}

abstract class InlineCommand {
  Stream<List<int>> get stdout;

  Stream<List<int>> get stderr;

  Sink<List<int>> get stdin;
}

abstract class InlineStringCommand {
  Stream<String> get stdout;

  Stream<String> get stderr;

  Sink<String> get stdin;
}

abstract class InlineLineCommand {
  Stream<String> get stdout;

  Stream<String> get stderr;

  Sink<String> get stdin;
}
