from multiprocessing.managers import BaseManager

DEFAULT_HOST = 'localhost'
DEFAULT_PORT = 12345
DEFAULT_AUTHKEY = b''


def serve(host: str, port: int, authkey: bytes):
    from idaapi import IDAPython_ExecScript, execute_sync, MFF_WRITE

    def execute(script: str) -> str:
        env = {'__name__': '__main__'}
        result = IDAPython_ExecScript(script, env)
        return result if result else ''

    BaseManager.register('execute', execute)
    manager = BaseManager((host, port), authkey)
    execute_sync(lambda: manager.get_server().serve_forever(), MFF_WRITE)


def PLUGIN_ENTRY():
    from idaapi import plugin_t, PLUGIN_UNL, PLUGIN_OK

    class Plugin(plugin_t):
        flags = PLUGIN_UNL
        comment = "IDAPy"
        help = "IDAPy"
        wanted_name = "IDAPy"
        wanted_hotkey = ""

        def init(self):
            return PLUGIN_OK

        def run(self, _):
            print('[IDAPy] start')
            serve(DEFAULT_HOST, DEFAULT_PORT, DEFAULT_AUTHKEY)

        def term(self):
            print('[IDAPy] stop')

    return Plugin()


def execute(host: str, port: int, authkey: bytes, script: str) -> str:
    BaseManager.register('execute')
    manager = BaseManager((host, port), authkey)
    manager.connect()
    return manager.execute(script)


def main():
    from argparse import ArgumentParser
    from pathlib import Path

    parser = ArgumentParser()
    parser.add_argument('script')
    args = parser.parse_args()

    script = args.script
    script = str(Path(script).absolute())
    result = execute(DEFAULT_HOST, DEFAULT_PORT, DEFAULT_AUTHKEY, script)
    print(result)


if __name__ == '__main__':
    main()
