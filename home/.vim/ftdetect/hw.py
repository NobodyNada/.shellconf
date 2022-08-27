import asyncio
import aiohttp.web as web
import signal
import traceback
import vim
from subprocess import Popen

buffer_contents = ""
ws_clients = set()

async def index(request):
    try:
        proc = await asyncio.create_subprocess_exec(
            "/usr/bin/env", "pandoc", "-d", "hw", "--standalone",
            stdout=asyncio.subprocess.PIPE, stdin=asyncio.subprocess.PIPE)
        stdout, stderr = await proc.communicate(input=buffer_contents.encode("utf-8"))
        return web.Response(text=stdout.decode("utf-8"), content_type="text/html")
    except:
        return web.Response(text=traceback.format_exc())

async def websocket(request):
    global ws_clients
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    ws_clients.add(ws)

    async for msg in ws:
        if msg.type == aiohttp.WSMsgType.CLOSED_FRAME or msg.type == aiohttp.WSMsgType.ERROR:
            break
    ws_clients.remove(ws)


async def run(dir):
    app = web.Application()
    app.router.add_route('GET', '/', index)
    app.router.add_route('GET', '/ws', websocket)
    app.router.add_static('/', dir)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, 'localhost', 0)
    await site.start()

    url = "http://localhost:%s" % runner.addresses[0][1]
    Popen(['open', url])

    try:
        await asyncio.sleep(3600)
    except asyncio.CancelledError:
        await runner.cleanup()

def main():
    global buffer_contents
    buffer_contents = "\n".join(vim.current.buffer[:])
    asyncio.ensure_future(run(vim.eval('expand("%:h")')))

def refresh():
    global buffer_contents
    buffer_contents = "\n".join(vim.current.buffer[:])
    asyncio.ensure_future(refresh_clients())

async def refresh_clients():
    global ws_clients
    proc = await asyncio.create_subprocess_exec(
        "/usr/bin/env", "pandoc", "-d", "hw_bare",
        stdout=asyncio.subprocess.PIPE, stdin=asyncio.subprocess.PIPE)
    stdout, stderr = await proc.communicate(input=buffer_contents.encode("utf-8"))
    text = stdout.decode("utf-8")

    for client in ws_clients:
        await client.send_str(text)
