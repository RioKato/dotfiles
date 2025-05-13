#!/usr/bin/python

import os
import subprocess
import urllib.parse
import shutil


def trans(url: str) -> str:
    chrome = os.getenv("CHROME_PATH") or "chrome"
    chrome = shutil.which(chrome)

    if not chrome:
        raise FileNotFoundError("chrome not found")

    netloc = urllib.parse.urlparse(url).netloc

    if not netloc.endswith(".translate.goog"):
        params = {"hl": "en", "sl": "auto", "tl": "ja", "u": url}
        params = urllib.parse.urlencode(params)
        url = f"https://translate.google.com/website?{params}"

    command = [chrome, "--headless", "--dump-dom", url]
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

    html = trans(url)

    if w3murl:
        print("Content-Type: text/html")
        print(f"Content-Lenght: {len(html)}")
        print()
        print(html)
    else:
        print(html)


if __name__ == "__main__":
    main()
