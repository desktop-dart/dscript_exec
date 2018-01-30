part of dscript.exec;

class CommandImpl extends Object with RunnerMixin implements Command {
  final String executable;

  final List<String> args;

  CommandImpl(this.executable, this.args);

  Command operator |(/* Command | InlineFunc | InlineStringFunc */ cmd) {
    if (cmd is Command) return pipe(cmd);
    if (cmd is InlineFunc) return pipeInline(cmd);
    if (cmd is InlineStringFunc) return pipeInlineString(cmd);
    throw new UnsupportedError(
        'Pipe operation not supported for provided command!');
  }

  Command operator >(
          /* File | Uri | StreamConsumer<List<int>> | StreamConsumer<String> | StringBuffer | List<int> */ src) =>
      new CompositeCmd(this, [new OutputRedirect(src)]);

  Command operator <(
          /* File | Uri | List<int> | Stream<List<int>> | String */ dest) =>
      new CompositeCmd(this, [new InputRedirect(dest)]);

  Command pipe(Command cmd) => new CompositeCmd(this, [new Pipe(cmd)]);

  Command pipeInline(InlineFunc cmd) =>
      new CompositeCmd(this, [new InlinePipe(cmd)]);

  Command pipeInlineString(InlineStringFunc cmd) =>
      new CompositeCmd(this, [new InlineStringPipe(cmd)]);

  Command pipeInlineLine(InlineStringFunc cmd) =>
      new CompositeCmd(this, [new InlineLinePipe(cmd)]);

  Future<Process> run({FutureOr onFinish(Process process)}) async {
    final Process process = await Process.start(executable, args);
    if (onFinish != null) await onFinish(process);
    return process;
  }
}
