from typing import Iterator


class Declare(gdb.Command):
    def __init__(self):
        super().__init__('declare', gdb.COMMAND_FILES)

    def invoke(self, arg: str, _):
        if not arg:
            return

        command = [
            'gcc', '-g', '-fno-eliminate-unused-debug-types', '-x', 'c', '-c', arg
        ]
        subprocess.run(command)
        obj = pathlib.Path(arg).with_suffix('.o').name
        gdb.execute(f'add-symbol-file {obj}')


class Offset(gdb.Command):
    @staticmethod
    def mappings() -> Iterator[tuple[int, str]]:
        from re import compile

        result = gdb.execute('info proc mappings', False, True)
        assert (result)
        pattern = compile(r'(0x[0-9a-f]+)')

        for line in result.splitlines():
            if found := pattern.search(line):
                base, = found.groups()
                base = int(base, 16)
                yield (base, line)

    def __init__(self):
        super().__init__('offset', gdb.COMMAND_USER)

    def invoke(self, arg: str, _):
        addr = gdb.parse_and_eval(arg)
        addr = int(addr)

        for (base, line) in Offset.mappings():
            offset = addr - base
            GREEN = '\033[32m'
            PURPLE = '\033[35m'
            END = '\033[0m'

            if offset >= 0:
                print(f'{GREEN}{offset:+#019x}{END} {line}')
            else:
                print(f'{PURPLE}{offset:+#019x}{END} {line}')


Declare()
Offset()
