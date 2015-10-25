import socket
import asyncio
import binascii
import random

REQUIRED_PLAYERS = 2
NUM_OF_LEVELS = 7
started = False
clientsArr = [0]*REQUIRED_PLAYERS
clientsReceived = 0
clients = []
positions = []
level = 0
grid = []
items = ""

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
    global level, positions, grid, items
    level = random.randint(0, NUM_OF_LEVELS-1)
    f = open('assets/data/level'+str(level)+'.txt', 'r')
    s = f.read()
    f.close()
    grid = [list(map(int, x.split(','))) for x in s.strip().split("\n")]
    positions = [getRandomPos() for x in range(REQUIRED_PLAYERS)]
    h = len(grid)
    w = len(grid[0])

    items = ['0']*(w*h)
    for i in range(w*h//10):
        items[random.randint(0, w*h-1)] = '1'
    for i in range(w*h//10):
        items[random.randint(0, w*h-1)] = '2'
    items = "".join(items)

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
        global clients, started, clientsReceived, clientsArr, items
        message = str(data.decode("ascii"))
        print(message)

        if message.strip() == 'READY':
            print("Host: someone connected")
            if len(clients) >= REQUIRED_PLAYERS:
                print("Host: clients slots exceeded! fuck off!")
                self.transport.close()
                return
            self.id = len(clients)
            print("Host: client number "+str(self.id)+" connected!")
            clients.append(self)

        if len(clients)>=REQUIRED_PLAYERS and not started:
            print("Host: all clients connected!")
            print("Host: sending data to clients...")
            started = True
            allPos = ":".join(["x".join((str(positions[x][0]), str(positions[x][1]))) for x in range(REQUIRED_PLAYERS)])
            for i in clients:
                i.transport.write(('START:'+str(i.id)+':'+str(level)+'\n'+allPos+'\n'+items+"\n").encode('ascii'))
                print("Host: sending \""+'START:'+str(i.id)+':'+str(level)+'\n'+allPos+"\n"+items+"\"")
            return
        if len(clients)>=REQUIRED_PLAYERS:
            print("Host: received: \""+message+"\"")
            d = list(map(int, message.split(':')))
            clientsArr[d[0]] = d[1]
            clientsReceived += 1
        if clientsReceived == REQUIRED_PLAYERS:
            print("Host: all clients reported their events - sending data...")
            for i in clients:
                i.transport.write((":".join(list(map(str, clientsArr)))+'\n').encode('ascii'))
                print("Host: sending \""+":".join(list(map(str, clientsArr)))+"\" to client number "+str(i.id))
            clientsReceived = 0

    def eof_received(self):
        self.transport.close()

init()
loop = asyncio.get_event_loop()
coro = loop.create_server(EchoServerClientProtocol, '10.10.97.146', 9911)
server = loop.run_until_complete(coro)
try:
    loop.run_forever()
except KeyboardInterrupt:
    pass
server.close()
loop.run_until_complete(server.wait_closed())
loop.close()
