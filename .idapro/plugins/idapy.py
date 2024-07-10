DEFAULT_HOST = 'localhost'
DEFAULT_PORT = 12345


def PLUGIN_ENTRY():
    from idaapi import plugin_t, PLUGIN_UNL, PLUGIN_OK

    class Plugin(plugin_t):
        flags = PLUGIN_UNL
        comment = "IDAPy"
        help = "IDAPy"
        wanted_name = "IDAPy"
        wanted_hotkey = ""
        host = DEFAULT_HOST
        port = DEFAULT_PORT

        def init(self):
            return PLUGIN_OK

        def run(self, _):
            print('[IDAPy] start')

            from xmlrpc.server import SimpleXMLRPCServer, SimpleXMLRPCRequestHandler
            from idaapi import IDAPython_ExecScript, execute_sync, MFF_WRITE

            def execute(script: str):
                def task():
                    env = {'__name__': '__main__'}
                    IDAPython_ExecScript(script, env)
                    return 0

                execute_sync(task, MFF_WRITE)
                return ''

            with SimpleXMLRPCServer((self.host, self.port), SimpleXMLRPCRequestHandler) as server:
                server.register_function(execute)
                server.serve_forever()

        def term(self):
            print('[IDAPy] stop')

    return Plugin()


def execute(host: str, port: int, script: str):
    from xmlrpc.client import ServerProxy
    client = ServerProxy(f'http://{host}:{port}')
    client.execute(script)


def main():
    from argparse import ArgumentParser
    from pathlib import Path

    parser = ArgumentParser()
    parser.add_argument('script')
    args = parser.parse_args()

    script = args.script
    script = str(Path(script).absolute())
    execute(DEFAULT_HOST, DEFAULT_PORT, script)


if __name__ == '__main__':
    main()
