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


def dumpreq(request: http.Request) -> str:
    request = request.copy()
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

    parsed = urlparse(request.url)
    url = urlunparse(parsed._replace(query=""))
    query = parse_qs(parsed.query, True)

    command = f"{request.method} {url}\n"

    for k, v in request.headers.items(multi=True):
        command += f"{k}: {v}\n"

    if query:
        command += "\n[Query]\n"

        for k, v in query.items():
            assert len(v) == 1
            v = v[0]
            command += f"{k}: {v}\n"

    if cookies:
        command += "\n[Cookies]\n"

        for k, v in cookies.items():
            v = v.value
            command += f"{k}: {v}\n"

    if request.content:
        content = request.content.decode()

        if not content.endswith("\n"):
            content = content + "\n"

        command += f"\n```{content_type}\n{content}```\n"

    return command


def dumpres(response: http.Response) -> str:
    response = response.copy()
    response.decode(strict=False)

    command = f"# HTTP {response.status_code}\n"

    for k, v in response.headers.items(multi=True):
        command += f"# {k}: {v}\n"

    if response.content:
        command += "\n# ```\n# ????\n# ```\n"

    return command


class Hurl:
    @command.command("hurl")
    def save(self, flows: Sequence[flow.Flow], path: mitmproxy.types.Path) -> None:
        command = ""

        for i, flow in enumerate(flows):
            assert isinstance(flow, http.HTTPFlow)

            command += "#" * 15 + "\n"
            command += f"# request {i:>3} #\n"
            command += "#" * 15 + "\n\n"
            command += dumpreq(flow.request)
            command += "\n"

            if flow.response:
                command += dumpres(flow.response)
                command += "\n"

        try:
            with open(path, "w") as fp:
                fp.write(command)
        except OSError as e:
            logging.error(str(e))


addons = [Hurl()]
