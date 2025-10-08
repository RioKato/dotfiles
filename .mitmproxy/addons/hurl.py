# Usage
# :hurl (@focus|@all) dump.hurl

from collections.abc import Sequence
from http.cookies import SimpleCookie
import logging
import mitmproxy.types
from mitmproxy import command
from mitmproxy import flow
from mitmproxy import http
from urllib.parse import urlparse, urlunparse, parse_qs


class Hurl:
    @command.command("hurl")
    def save(self, flows: Sequence[flow.Flow], path: mitmproxy.types.Path) -> None:
        command = []

        for i, flow in enumerate(flows):
            assert isinstance(flow, http.HTTPFlow)
            request = flow.request.copy()
            request.decode(strict=False)

            request.headers.pop("content-length", None)

            content_type = ""
            if "content-type" in request.headers:
                match request.headers.get("content-type", ""):
                    case "application/json":
                        content_type = "json"

                if content_type:
                    request.headers.pop("content-type")

            cookies = None
            if "cookie" in request.headers:
                cookies = SimpleCookie()
                cookies.load(request.headers.get("cookie", ""))
                request.headers.pop("cookie")

            command.append(f"#" * 15)
            command.append(f"# request {i:>3} #")
            command.append(f"#" * 15)
            command.append("")

            parsed = urlparse(request.url)
            url = urlunparse(parsed._replace(query=""))
            query = parse_qs(parsed.query, True)
            command.append(f"{request.method} {url}")

            for k, v in request.headers.items(multi=True):
                command.append(f"{k}: {v}")

            if query:
                command.append("")
                command.append("[Query]")

                for k, v in query.items():
                    assert len(v) == 1
                    v = v[0]
                    command.append(f"{k}: {v}")

            if cookies:
                command.append("")
                command.append("[Cookies]")

                for k, v in cookies.items():
                    v = v.value
                    command.append(f"{k}: {v}")

            if request.content:
                content = request.content.decode()

                if content.endswith("\n"):
                    content = content[:-1]

                command.append("")
                command.append(f"```{content_type}")
                command.append(content)
                command.append("```")

            command.append("")

        command = "\n".join(command)

        try:
            with open(path, "w") as fp:
                fp.write(command)
        except OSError as e:
            logging.error(str(e))


addons = [Hurl()]
