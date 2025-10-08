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


class Hurl:
    @command.command("hurl")
    def save(self, flows: Sequence[flow.Flow], path: mitmproxy.types.Path) -> None:
        command = []

        for i, flow in enumerate(flows):
            request = cleanup_request(flow)

            request.headers.pop("content-length", None)

            content_type = ""
            match request.headers.get("content-type", ""):
                case "application/json":
                    content_type = "json"

            if content_type:
                request.headers.pop("content-type")

            command.append(f"# request {i}")
            command.append(f"{request.method} {request.url}")

            for k, v in request.headers.items(multi=True):
                command.append(f"{k}: {v}")

            if request.content:
                content = request.content.decode()

                if content.endswith("\n"):
                    content = content[:-1]

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
