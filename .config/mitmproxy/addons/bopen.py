from mitmproxy import command
from mitmproxy import flow
from tempfile import mkstemp
import webbrowser


class BOpen:
    @command.command("bopen")
    def open(self, flow: flow.Flow):
        if flow.response:
            response = flow.response.copy()
            response.decode(strict=False)
            temp = mkstemp()

            with open(temp[1], "w+b") as fd:
                fd.write(response.content)
                webbrowser.open(temp[1])


addons = [BOpen()]
