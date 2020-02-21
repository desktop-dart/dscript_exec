library dscript.exec;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

part 'cmd_composite.dart';
part 'cmd_impl.dart';
part 'runner_mixin.dart';
part 'subcmd.dart';

/// Invokes a command with [executable] and [args]
///
/// Example:
///     await exec('rm', ['example/dest.csv']).run();
Command exec(String executable, [List<String> args = const []]) =>
    CommandImpl(executable, args);

abstract class Command {
  /// Executable of the command
  String get executable;

  /// Command line arguments supplied to the command
  List<String> get args;

  /// Pipes output of this command to the input of next command. The next command
  /// could be [Command], [InlineFunc] or [InlineStringFunc].
  ///
  /// Example:
  ///     await (exec('cat', ['example/names.csv']) |
  ///       exec('cut', ['-d', "','", '-f', '1']))
  ///       .runGetOutput(onFinish: print);
  Command operator |(/* Command | InlineFunc | InlineStringFunc */ cmd);

  /// Redirects the out of this command to [dest].
  ///
  /// [dest] could be a [File], [Uri], [StreamConsumer]<List<int>>,
  /// [StreamConsumer]<String>, [StringBuffer] or [List]<int>.
  ///
  /// If it is a [File], the output of this command is written to the file.
  /// If it is a [Uri] pointing to a file in the file system, the output of this
  /// command is written to the file.
  /// If it is a [StreamConsumer]<List<int>>, the output of this command is
  /// written to the stream consumer.
  /// If it is a [StreamConsumer]<String>, the output of this command is
  /// converted to [String] and written to the stream consumer.
  ///
  /// Example:
  ///     await (exec('cat', ['example/names.csv']) |
  ///       exec('cut', ['-d', "','", '-f', '1']) >
  ///       new Uri(path: 'example/dest.csv'))
  ///       .run();
  Command operator >(
      /* File | Uri | StreamConsumer<List<int>> | StreamConsumer<String> | StringBuffer | List<int> */
      dest);

  /// Redirects the contents of [src] to the stdin of this command.
  ///
  /// Example:
  ///     await (exec('cut', ['-d', "','", '-f', '1']) <
  ///       '''
  ///     John,Smith,34,London
  ///     Arthur,Evans,21,Newport
  ///     George,Jones,32,Truro
  ///       ''')
  ///       .runGetOutput(onFinish: print);
  Command operator <(
      /* File | Uri | List<int> | Stream<List<int>> | String */
      src);

  /// Pipes output of this command to the input of next command
  ///
  /// Example:
  ///     await exec('cat', ['example/names.csv'])
  ///         .pipe(exec('cut', ['-d', "','", '-f', '1']))
  ///         .runGetOutput(onFinish: print);
  Command pipe(Command cmd);

  /// Pipes output of this command to the input of [InlineFunc]
  ///
  /// Example:
  ///     await exec('cat', ['example/names.csv'])
  ///         .pipe(exec('cut', ['-d', "','", '-f', '1']))
  ///         .runGetOutput(onFinish: print);
  Command pipeInline(InlineFunc cmd);

  /// Pipes output of this command to the input of [InlineStringFunc]
  ///
  /// Example:
  ///     await exec('cat', ['example/names.csv'])
  ///         .pipe(exec('cut', ['-d', "','", '-f', '1']))
  ///         .runGetOutput(onFinish: print);
  Command pipeInlineString(InlineStringFunc cmd);

  /// Pipes output of this command to the input of [InlineStringFunc]
  ///
  /// Example:
  ///     await exec('cat', ['example/names.csv'])
  ///         .pipeInlineLine(
  ///     (Stream<String> stream) => stream.map((s) => s.split(',')[1]))
  ///         .runGetOutput(onFinish: print);
  Command pipeInlineLine(InlineStringFunc cmd);

  /// Runs the command pipeline and returns the [Process] instance of final
  /// process
  Future<Process> run();

  /// Runs the command pipeline and returns the string output of final process
  Future<String> stdout();

  Future<int> exitCode();
}

class Result {
  final int status;

  final String stdin;

  final String stdout;

  final int pid;

  Result(this.status, this.stdin, this.stdout, this.pid);
}
