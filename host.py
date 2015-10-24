import socket
import asyncio
import binascii
import random

REQUIRED_PLAYERS = 2
started = False
clientsArr = [0]*REQUIRED_PLAYERS
clientsReceived = 0
clients = []
positions = []

def getRandomPos():
    return (random.randint(0,4), random.randint(0, 4))


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
        #wszyscy klienci dali nam swoje współrzędne, więc wysyłamy wszystkim wszystkie współrzędne
        if clientsReceived == REQUIRED_PLAYERS:
            for i in clients:
                i.transport.write((":".join(list(map(str, clientsArr)))+'\n').encode('ascii'))
            clientsReceived = 0

    def eof_received(self):
        self.transport.close()

positions = [getRandomPos() for x in range(REQUIRED_PLAYERS)]
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
