part of dscript.exec;

class CommandImpl extends Object with RunnerMixin implements Command {
  final String executable;

  final List<String> args;

  CommandImpl(this.executable, [this.args = const []]);

  Command operator |(/* Command | InlineFunc | InlineStringFunc */ cmd) {
    if (cmd is Command) return pipe(cmd);
    if (cmd is InlineFunc) return pipeInline(cmd);
    if (cmd is InlineStringFunc) return pipeInlineString(cmd);
    throw UnsupportedError(
        'Pipe operation not supported for provided command!');
  }

  Command operator >(
          /* File | Uri | StreamConsumer<List<int>> | StreamConsumer<String> | StringBuffer | List<int> */ src) =>
      CompositeCmd(this, [OutputRedirect(src)]);

  Command operator <(
          /* File | Uri | List<int> | Stream<List<int>> | String */ dest) =>
      CompositeCmd(this, [InputRedirect(dest)]);

  Command pipe(Command cmd) => CompositeCmd(this, [Pipe(cmd)]);

  Command pipeInline(InlineFunc cmd) => CompositeCmd(this, [InlinePipe(cmd)]);

  Command pipeInlineString(InlineStringFunc cmd) =>
      CompositeCmd(this, [InlineStringPipe(cmd)]);

  Command pipeInlineLine(InlineStringFunc cmd) =>
      CompositeCmd(this, [InlineLinePipe(cmd)]);

  Future<Process> run() async {
    final Process process = await Process.start(executable, args);
    return process;
  }
}
