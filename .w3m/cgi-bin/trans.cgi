#!/usr/bin/python

import subprocess
import urllib.parse


def chrome(url: str):
    params = {"hl": "en", "sl": "auto", "tl": "ja", "u": url}
    params = urllib.parse.urlencode(params)
    url = f"https://translate.google.com/translate?{params}"
    command = ["/opt/google/chrome/chrome", "--headless", "--dump-dom", url]
    stdin = stderr = subprocess.DEVNULL
    subprocess.run(command, stdin=stdin, stderr=stderr, text=True, check=True)


def main():
    import argparse
    import os

    url = os.getenv("W3M_URL")

    if not url:
        parser = argparse.ArgumentParser()
        parser.add_argument("url")
        args = parser.parse_args()
        url = args.url
    else:
        print("Content-Type: text/html")
        print()

    chrome(url)


if __name__ == "__main__":
    main()
