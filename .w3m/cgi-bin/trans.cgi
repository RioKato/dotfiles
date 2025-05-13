#!/usr/bin/python

import urllib.parse


def transurl(url: str) -> str:
    netloc = urllib.parse.urlparse(url).netloc

    if not netloc.endswith(".translate.goog"):
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
        url = [
            "w3m-control: BACK",
            f"w3m-control: GOTO {url}",
            "w3m-control: EXTERN",
        ]
        url = "\n".join(url)

    print(url)


if __name__ == "__main__":
    main()
