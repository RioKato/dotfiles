#!/usr/bin/python

import urllib.parse
import fnmatch


def transurl(url: str) -> str:
    hostname = urllib.parse.urlparse(url).hostname
    hostname = hostname or ""

    patterns = [
        "translate.google.com",
        "*.translate.goog",
    ]

    for p in patterns:
        if fnmatch.fnmatch(hostname, p):
            return ""

    params = {"hl": "en", "sl": "auto", "tl": "ja", "u": url}
    params = urllib.parse.urlencode(params)
    url = f"https://translate.google.com/website?{params}"
    return url


def main():
    import argparse
    import os

    w3murl = os.getenv("W3M_URL")

    if w3murl:
        url = w3murl
    else:
        parser = argparse.ArgumentParser()
        parser.add_argument("url")
        args = parser.parse_args()
        url = args.url

    url = transurl(url)

    if w3murl:
        headers = ""
        headers += "w3m-control: BACK\n"
        headers += f"w3m-control: GOTO {url}\n" if url else ""
        headers += "w3m-control: EXTERN\n"
        print(headers)
    else:
        print(url)


if __name__ == "__main__":
    main()
