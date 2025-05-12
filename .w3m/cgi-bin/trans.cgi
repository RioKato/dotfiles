#!/usr/bin/python

import subprocess
import urllib.parse


def chrome(url: str) -> str:
    params = {"hl": "en", "sl": "auto", "tl": "ja", "u": url}
    params = urllib.parse.urlencode(params)
    url = f"https://translate.google.com/translate?{params}"
    command = ["/opt/google/chrome/chrome", "--headless", "--dump-dom", url]
    stdin = stderr = subprocess.DEVNULL
    stdout = subprocess.PIPE
    return subprocess.run(
        command,
        stdin=stdin,
        stdout=stdout,
        stderr=stderr,
        text=True,
        check=True,
    ).stdout


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

    html = chrome(url)

    if w3murl:
        print("Content-Type: text/html")
        print(f"Content-Lenght: {len(html)}")
        print()
        print(html)
    else:
        print(html)


if __name__ == "__main__":
    main()
