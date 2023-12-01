from gdb import Command
from typing import Iterator


class Offset(Command):
    @staticmethod
    def mappings() -> Iterator[tuple[int, str]]:
        from gdb import execute
        from re import compile

        result = execute('info proc mappings', False, True)
        assert (result)
        pattern = compile(r'(0x[0-9a-f]+)')

        for line in result.splitlines():
            if found := pattern.search(line):
                base, = found.groups()
                base = int(base, 16)
                yield (base, line)

    def __init__(self):
        from gdb import COMMAND_USER
        super().__init__('offset', COMMAND_USER)

    def invoke(self, arg: str, _):
        from gdb import parse_and_eval
        addr = parse_and_eval(arg)
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


Offset()
