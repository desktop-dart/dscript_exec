# Exec

Bash like command piping and redirecting for Dart to make writing Dart
scripts easier.

Say good-bye to bash, python and batch file scripting! Invest in a sound
language with amazing analyzer tools!

From the authors of [Jaguar.dart](https://jaguar-dart.github.io/).

# Usage

## Execute a command

```dart
await exec('rm', ['example/dest.csv']).run();
```

## Access command output

```dart
final String out = await exec('cat', ['example/names.csv']).runGetOutput();
print(out);
```

or

```dart
await exec('cat', ['example/names.csv']).runGetOutput(onFinish: print);
```

## Pipe

```dart
await exec('cat', ['example/names.csv'])
  .pipe(exec('cut', ['-d', "','", '-f', '1']))
  .runGetOutput(onFinish: print);
```

## Output redirection

```dart
await (exec('cat', ['example/names.csv']) |
          exec('cut', ['-d', "','", '-f', '1']) >
      new Uri(path: 'example/dest.csv'))
  .run();
```

## Input redirection

```dart
await (exec('cut', ['-d', "','", '-f', '1']) <
      '''
John,Smith,34,London
Arthur,Evans,21,Newport
George,Jones,32,Truro
      ''')
  .runGetOutput(onFinish: print);
```

## Inline functions

```dart
await exec('cat', ['example/names.csv'])
  .pipeInlineLine(
      (Stream<String> stream) => stream.map((s) => s.split(',')[1]))
  .runGetOutput(onFinish: print);
```

# TODO

+ [ ] Catch and report error in sub-commands
+ [ ] Support other encoders
+ [ ] Support stderr redirection
+ [ ] Test multiple redirections
+ [ ] Support `&`, `|` and `~` concepts