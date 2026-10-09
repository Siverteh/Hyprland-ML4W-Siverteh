#!/usr/bin/env python3
"""Bounded HTTPS weather retrieval with private caching and truthful stale state."""

import json, time, urllib.request, urllib.parse
from pathlib import Path

HOME = Path.home()
CACHE = HOME / ".cache/nacre/weather.json"


def fetch_json(url):
    with urllib.request.urlopen(
        urllib.request.Request(url, headers={"User-Agent": "Nacre/1.0"}),
        timeout=8,
    ) as response:
        data = response.read(512001)
        if len(data) > 512000:
            raise ValueError("Weather response too large")
        return json.loads(data)


def refresh():
    try:
        settings = json.loads((HOME / ".config/nacre/desktop.json").read_text())
    except (OSError, ValueError):
        settings = {}
    try:
        previous = json.loads(CACHE.read_text())
    except (OSError, ValueError):
        previous = {}
    location = settings.get("weatherLocation", "").strip()
    try:
        if not location:
            location = fetch_json("https://ipinfo.io/json").get("city", "")
        if not location:
            raise ValueError("Set a weather city in Settings")
        forecast = fetch_json(
            "https://wttr.in/" + urllib.parse.quote(location, safe="") + "?format=j1"
        )
        weather = forecast["current_condition"][0]
        today = (forecast.get("weather") or [{}])[0]
        data = dict(
            location=location,
            code=weather["weatherCode"],
            description=weather["weatherDesc"][0]["value"],
            temperature=float(weather["temp_C"]),
            feelsLike=float(weather["FeelsLikeC"])
            if weather.get("FeelsLikeC")
            else None,
            high=float(today["maxtempC"]) if today.get("maxtempC") else None,
            low=float(today["mintempC"]) if today.get("mintempC") else None,
            checked=time.time(),
            stale=False,
            error="",
        )
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        temp = CACHE.with_suffix(".tmp")
        temp.write_text(json.dumps(data))
        temp.chmod(0o600)
        temp.replace(CACHE)
        return data
    except Exception:
        # Keep original check time; an unsuccessful refresh is not fresh weather.
        return dict(
            previous,
            stale=True,
            error="Weather unavailable; showing cached conditions"
            if previous
            else "Weather unavailable. Set a city or try again.",
        )


if __name__ == "__main__":
    print(json.dumps(refresh()))
