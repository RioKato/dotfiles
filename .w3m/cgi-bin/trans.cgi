#!env python

import subprocess
import urllib.parse


def chrome(url: str):
    params = {"hl": "en", "sl": "auto", "tl": "ja", "u": url}
    params = urllib.parse.urlencode(params)
    url = f"https://translate.google.com/translate?{params}"
    command = ["/opt/google/chrome/chrome", "--headless", "--dump-dom", url]
    subprocess.run(command, stderr=subprocess.DEVNULL, check=True)


def main():
    import argparse
    import os

    parser = argparse.ArgumentParser()

    if w3m_url := os.getenv("W3M_URL"):
        parser.add_argument("--url", "-u", default=w3m_url)
    else:
        parser.add_argument("url")

    args = parser.parse_args()
    chrome(args.url)


if __name__ == "__main__":
    main()
