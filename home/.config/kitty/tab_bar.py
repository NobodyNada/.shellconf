from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, wcwidth
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)
from kitty.utils import which
import subprocess
import sys

def _periodic(timer_id):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()

def _draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    separator_symbol, soft_separator_symbol = ('▋', '│')
    min_title_length = 1 + 2
    start_draw = 2

    if screen.cursor.x == 0:
        screen.cursor.bg = tab_bg
        screen.draw(' ')
        start_draw = 1

    screen.cursor.bg = tab_bg
    if min_title_length >= max_title_length:
        screen.draw('…')
    else:
        draw_title(draw_data, screen, tab, index, max_title_length)
        extra = screen.cursor.x + start_draw - before - max_title_length
        if extra > 0 and extra + 1 < screen.cursor.x:
            screen.cursor.x -= extra + 1
            screen.draw('…')

    if not needs_soft_separator:
        screen.draw(' ')
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(separator_symbol)
    else:
        prev_fg = screen.cursor.fg
        if tab_bg == tab_fg:
            screen.cursor.fg = default_bg
        elif tab_bg != default_bg:
            c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
            c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
            if c1 < c2:
                screen.cursor.fg = default_bg
        screen.draw(f' {soft_separator_symbol}')
        screen.cursor.fg = prev_fg

    end = screen.cursor.x
    if end < screen.columns:
        screen.draw(' ')
    return end

if sys.platform == "darwin":
    nowplaying_cli = which("media-control")
    nowplaying_process = None
    nowplaying_output = None
    def get_playback_status():
        import json
        global nowplaying_cli, nowplaying_process, nowplaying_output

        empty = {'title': None, 'artist': None, 'playbackRate': None}
        if nowplaying_output is None:
            nowplaying_output = empty

        if nowplaying_cli is not None:
            if nowplaying_process is None:
                nowplaying_process = subprocess.Popen(
                        [nowplaying_cli, "stream"],
                        stdout=subprocess.PIPE, encoding='utf-8')

            while True:
                import select
                ready, _, _ = select.select([nowplaying_process.stdout], [], [], 0)
                if len(ready) == 0:
                    break
                msg = json.loads(nowplaying_process.stdout.readline())
                if msg["type"] == "data":
                    if not msg["diff"]:
                        nowplaying_output = empty
                    data = msg["payload"]
                    for key in nowplaying_output.keys():
                        if data.get(key) is not None:
                            nowplaying_output[key] = data[key]

            title, artist, playback_rate = nowplaying_output["title"], nowplaying_output["artist"], nowplaying_output["playbackRate"]
            if title is None and artist is None and playback_rate is None:
                return None

            icon = "⏵" if playback_rate == "1" else "⏸"

            output = f"{icon} {title}"
            if artist not in ["null", ""]:
                output += " - " + artist
            return output

        return None
elif sys.platform == "linux":
    # https://stackoverflow.com/a/33923095
    import dbus
    spotify_properties = None
    def get_playback_status():
        try:
            global spotify_properties
            if spotify_properties is None:
                session_bus = dbus.SessionBus()
                spotify_bus = session_bus.get_object("org.mpris.MediaPlayer2.spotify",
                                                     "/org/mpris/MediaPlayer2")
                spotify_properties = dbus.Interface(spotify_bus,
                                                    "org.freedesktop.DBus.Properties")
            metadata = spotify_properties.Get("org.mpris.MediaPlayer2.Player", "Metadata")
            playback_status = spotify_properties.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus")

            icon = "⏵" if playback_status == "Playing" else "⏸"
            title = metadata['xesam:title']
            artist = ", ".join(metadata['xesam:artist'])
            return f"{icon} {title} - {artist}"

        except dbus.DBusException:
            spotify_properties = None
            return None
else:
    def get_playback_status():
        return None

def draw_status(draw_data: DrawData, screen: Screen) -> int:
    import datetime
    active_fg = as_rgb(int(draw_data.active_fg))
    inactive_fg = as_rgb(int(draw_data.inactive_fg))
    active_bg = as_rgb(int(draw_data.active_bg))
    inactive_bg = as_rgb(int(draw_data.inactive_bg))
    default_bg = as_rgb(int(draw_data.default_bg))

    if screen.cursor.x == 0:
        screen.cursor.bg = default_bg

    clock = datetime.datetime.now().strftime(" %-I:%M ")
    cells = [
        (active_fg, inactive_bg, clock),
    ]

    song = get_playback_status()
    if song is not None:
        cells.append((inactive_fg, default_bg, " " + song + " "))

    cells_to_draw = []

    characters = screen.columns - screen.cursor.x
    for cell in cells:
        (fg, bg, text) = cell
        width = sum(map(lambda x: wcwidth(ord(x)), text))
        if width < characters:
            cells_to_draw = [cell] + cells_to_draw
            characters -= width
        else:
            break

    screen.cursor.fg = default_bg
    screen.draw(' ' * (characters))
    for (fg, bg, text) in cells_to_draw:
        screen.cursor.fg = fg
        screen.cursor.bg = bg
        screen.draw(text)
    return screen.cursor.x

timer_id = None

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id
    if timer_id is None:
        timer_id = add_timer(_periodic, 2.0, True)
    if not (index == 1 and is_last):
        cursor_x = _draw_tab(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data)
    if is_last:
        return draw_status(draw_data, screen)
    else:
        return cursor_x
    
