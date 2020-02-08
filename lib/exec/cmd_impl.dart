part of dscript.exec;

class CommandImpl extends Object with RunnerMixin implements Command {
  @override
  final String executable;

  @override
  final List<String> args;

  CommandImpl(this.executable, [this.args = const []]);

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
          /* File | Uri | StreamConsumer<List<int>> | StreamConsumer<String> | StringBuffer | List<int> */ src) =>
      CompositeCmd(this, [OutputRedirect(src)]);

  @override
  Command operator <(
          /* File | Uri | List<int> | Stream<List<int>> | String */ dest) =>
      CompositeCmd(this, [InputRedirect(dest)]);

  @override
  Command pipe(Command cmd) => CompositeCmd(this, [Pipe(cmd)]);

  @override
  Command pipeInline(InlineFunc cmd) => CompositeCmd(this, [InlinePipe(cmd)]);

  @override
  Command pipeInlineString(InlineStringFunc cmd) =>
      CompositeCmd(this, [InlineStringPipe(cmd)]);

  @override
  Command pipeInlineLine(InlineStringFunc cmd) =>
      CompositeCmd(this, [InlineLinePipe(cmd)]);

  @override
  Future<Process> run() async {
    final process = await Process.start(executable, args);
    return process;
  }
}
