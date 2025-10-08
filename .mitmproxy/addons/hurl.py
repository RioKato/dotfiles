from collections.abc import Sequence
import logging
import mitmproxy.types
from mitmproxy import command
from mitmproxy import exceptions
from mitmproxy import flow
from mitmproxy import http


def cleanup_request(f: flow.Flow) -> http.Request:
    if not getattr(f, "request", None):
        raise exceptions.CommandError("Can't export flow with no request.")
    assert isinstance(f, http.HTTPFlow)
    request = f.request.copy()
    request.decode(strict=False)
    return request


def pop_headers(request: http.Request) -> None:
    request.headers.pop("content-length", None)

    if request.headers.get("host", "") == request.host:
        request.headers.pop("host")


class Hurl:
    @command.command("hurl")
    def save(self, flows: Sequence[flow.Flow], path: mitmproxy.types.Path) -> None:
        command = []

        for i, flow in enumerate(flows):
            request = cleanup_request(flow)
            pop_headers(request)

            command.append(f"# request {i}")
            command.append(f"{request.method} {request.url}")

            for k, v in request.headers.items(multi=True):
                command.append(f"{k}: {v}")

            if request.content:
                content = request.content.decode()
                command.append(f"```")
                command.append(content)
                command.append(f"```")

            command.append("")

        command = "\n".join(command)

        try:
            with open(path, "w") as fp:
                fp.write(command)
        except OSError as e:
            logging.error(str(e))


addons = [Hurl()]
