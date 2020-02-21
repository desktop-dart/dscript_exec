part of dscript.exec;

class CompositeCmd extends Object with RunnerMixin implements Command {
  final Command first;

  final List<Op> ops;

  CompositeCmd(this.first, [this.ops = const []]);

  @override
  String get executable => first.executable;

  @override
  List<String> get args => first.args;

  @override
  Command operator |(/* Command | InlineFunc | InlineStringFunc */ cmd) {
    if (cmd is Command) return pipe(cmd);
    if (cmd is InlineFunc) return pipeInline(cmd);
    if (cmd is InlineStringFunc) return pipeInlineString(cmd);
    throw UnsupportedError(
        'Pipe operation not supported for provided command!');
  }

  @override
  Command operator >(
      /* File | Uri | StreamConsumer<List<int>> | StreamConsumer<String> | StringBuffer | List<int> */
      file) {
    ops.add(OutputRedirect(file));
    return this;
  }

  @override
  Command operator <(
      /* File | Uri | List<int> | Stream<List<int>> | String */
      file) {
    ops.add(InputRedirect(file));
    return this;
  }

  @override
  Command pipe(Command cmd) {
    ops.add(Pipe(cmd));
    return this;
  }

  @override
  Command pipeInline(InlineFunc cmd) {
    ops.add(InlinePipe(cmd));
    return this;
  }

  @override
  Command pipeInlineString(InlineStringFunc cmd) {
    ops.add(InlineStringPipe(cmd));
    return this;
  }

  @override
  Command pipeInlineLine(InlineStringFunc cmd) {
    ops.add(InlineLinePipe(cmd));
    return this;
  }

  @override
  Future<Process> run({FutureOr Function(Process process) onFinish}) async {
    Process last = await first.run();
    for (Op sc in ops) {
      last = await sc.runWith(last);
    }
    if (onFinish != null) await onFinish(last);
    return last;
  }
}
