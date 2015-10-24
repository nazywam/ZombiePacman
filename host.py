import socket
import asyncio
import binascii
import random

REQUIRED_PLAYERS = 2
NUM_OF_LEVELS = 14
started = False
clientsArr = [0]*REQUIRED_PLAYERS
clientsReceived = 0
clients = []
positions = []
level = 0
grid = []

def getRandomPos():
    global grid
    h = len(grid)
    w = len(grid[0])
    x = random.randint(0, w-1)
    y = random.randint(0, h-1)
    while grid[y][x] != 0:
        x = random.randint(0, w-1)
        y = random.randint(0, h-1)
    grid[y][x] = -1
    return (x, y)

def init():
    global level, positions, grid
    level = random.randint(1, NUM_OF_LEVELS)
    f = open('assets/data/level'+str(level)+'.txt', 'r')
    s = f.read()
    f.close()
    print(s)
    grid = [list(map(int, x.split(','))) for x in s.strip().split("\n")]
    print(grid)
    positions = [getRandomPos() for x in range(REQUIRED_PLAYERS)]

class EchoServerClientProtocol(asyncio.Protocol):

    def start_server(loop, host, port):
        f = loop.create_server(EchoServer, host, port)
        return loop.run_until_complete(f)

    def connection_made(self, transport):
        global clients
        peername = transport.get_extra_info('peername')
        print('Connection from {}'.format(peername))
        self.transport = transport


    def data_received(self, data):
        global clients, started, clientsReceived, clientsArr
        message = str(data.decode("ascii"))
        print(message)

        if message.strip() == 'READY':
            self.id = len(clients)
            clients.append(self)

        if len(clients)>=REQUIRED_PLAYERS and not started:
            started = True
            print(positions)
            allPos = ":".join(["x".join((str(positions[x][0]), str(positions[x][1]))) for x in range(REQUIRED_PLAYERS)])
            for i in clients:
                i.transport.write(('START:'+str(i.id)+':1\n'+allPos+'\n').encode('ascii'))
            return
        if len(clients)>=REQUIRED_PLAYERS:
            print(message)
            d = list(map(int, message.split(':')))
            print(d)
            clientsArr[d[0]] = d[1]
            clientsReceived += 1
        if clientsReceived == REQUIRED_PLAYERS:
            for i in clients:
                i.transport.write((":".join(list(map(str, clientsArr)))+'\n').encode('ascii'))
            clientsReceived = 0

    def eof_received(self):
        self.transport.close()

init()
loop = asyncio.get_event_loop()
coro = loop.create_server(EchoServerClientProtocol, '127.0.0.1', 8880)
server = loop.run_until_complete(coro)
try:
    loop.run_forever()
except KeyboardInterrupt:
    pass
server.close()
loop.run_until_complete(server.wait_closed())
loop.close()
