part of dscript.exec;

class CompositeCmd extends Object with RunnerMixin implements Command {
  final Command first;

  final List<Op> ops;

  CompositeCmd(this.first, [this.ops = const []]);

  String get executable => first.executable;

  List<String> get args => first.args;

  Command operator |(/* Command | InlineFunc | InlineStringFunc */ cmd) {
    if (cmd is Command) return pipe(cmd);
    if (cmd is InlineFunc) return pipeInline(cmd);
    if (cmd is InlineStringFunc) return pipeInlineString(cmd);
    throw new UnsupportedError(
        'Pipe operation not supported for provided command!');
  }

  Command operator >(
      /* File | Uri | StreamConsumer<List<int>> | StreamConsumer<String> | StringBuffer | List<int> */ file) {
    ops.add(new OutputRedirect(file));
    return this;
  }

  Command operator <(
      /* File | Uri | List<int> | Stream<List<int>> | String */ file) {
    ops.add(new InputRedirect(file));
    return this;
  }

  Command pipe(Command cmd) {
    ops.add(new Pipe(cmd));
    return this;
  }

  Command pipeInline(InlineFunc cmd) {
    ops.add(new InlinePipe(cmd));
    return this;
  }

  Command pipeInlineString(InlineStringFunc cmd) {
    ops.add(new InlineStringPipe(cmd));
    return this;
  }

  Command pipeInlineLine(InlineStringFunc cmd) {
    ops.add(new InlineLinePipe(cmd));
    return this;
  }

  Future<Process> run({FutureOr onFinish(Process process)}) async {
    Process last = await first.run();
    for (Op sc in ops) {
      last = await sc.runWith(last);
    }
    if (onFinish != null) await onFinish(last);
    return last;
  }
}
