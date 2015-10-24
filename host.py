'''
    Simple socket server using threads
'''

import socket
import sys
from threading import *
import random
HOST = ''   # Symbolic name meaning all available interfaces
PORT = 8787  # Arbitrary non-privileged port
players = []
joined_flag = len(players)
started_flag = False
no_players_req = 2  # number of players required to START
map_no = random.randint(1, 9)
map_data_tmp = []
map_data = []

with open('assets/data/level'+str(map_no)+'.txt', 'r') as f:
    map_data_tmp=(f.read().split('\n'))
    for i in map_data_tmp:
        map_data.append(i.split(','))
#print map_data
print len(map_data)
print len(map_data[0])
class Player():
    player_count = 0
    ready_players = 0

    def __init__(self, conn):
        global map_data
        """
        self.direction
        0 -> UP
        1 -> RIGHT
        2 -> DOWN
        3 -> RIGHT
        """
        self.conn = conn
        self.direction = 0
        self.id_c = Player.player_count
        Player.player_count += 1
        self.x = random.randint(0, 15)
        self.y = random.randint(0, 15)
        self.started_flag=False
    def set_ready(self):
        global players, joined_flag, no_players_req
        Player.ready_players += 1
        joined_flag = len(players)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Socket created'

# Bind socket to local host and port
try:
    s.bind((HOST, PORT))
except socket.error as msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()

print 'Socket bind complete'

# Start listening on socket
s.listen(10)
print 'Socket now listening'

# Function for handling connections. This will be used to create threads


def clientthread(conn, id_c):
    global players, joined_flag, no_players_req, map_no
    lock = Lock()
    # Sending message to connected client
    # conn.send('Welcome to the server. Type something and hit enter\n') #send
    # only takes string
    data = conn.recv(1024).strip()
    print data
    if data == 'READY':
        players[id_c].set_ready()
    # infinite loop so that function do not terminate and thread do not end.
    while True:
        if joined_flag:
#            print 'joined_flag', joined_flag
            print("lock 1 acquired ", id_c)
            lock.acquire()
            try:
                joined_flag -= 1
                print str(Player.ready_players) + '/' + str(no_players_req)+'\n'
                conn.sendall(str(Player.ready_players) + '/' + str(no_players_req)+'\n')
            finally:
                print("lock 1 released ", id_c)
                lock.release()
            if Player.ready_players >= no_players_req and not started_flag:
                conn.sendall('START\n')
                conn.sendall(str(id_c)+' '+str(map_no)+'\n')
                res = ''
                for i in xrange(len(players)):
                    if(i == len(players)-1):
                        res += str(players[i].x)+'x'+str(players[i].y)
                    else:
                        res += str(players[i].x)+'x'+str(players[i].y)+'_'    
                    
                res+='\n'
                print("pozycje poczatkowe graczy", res)
                conn.sendall(res)
                players[id_c].started_flag=True
            if players[id_c].started_flag:
                print("lock 2 acquired ", id_c)
                lock.acquire()
                try:
                    players[id_c].direction=conn.recv(1024).strip()
                    #print(id_c, ' id klienta i jego kierunek ', players[id_c].direction)
                finally:
                    print("lock 2 released ", id_c)
                    lock.release()
                print("lock 3 acquired ", id_c)
                lock.acquire()
                try:
                    for i in xrange(len(players)):
                        if i==(len(players)-1):
                            res += str(players[i].direction)
                        else:
                            res += str(players[i].direction)+'_'    

                    res+='\n'
                    print('kierunki', res)
                    conn.sendall(res)
                finally:
                    print("lock 3 released ", id_c)
                    lock.release()
            print 'wysylam'
        # Receiving from client

    conn.close()

# now keep talking with the client
while 1:
    # wait to accept a connection - blocking call
    conn, addr = s.accept()
    print 'Connected with ' + addr[0] + ':' + str(addr[1])

    # start new thread takes 1st argument as a function name to be run, second
    # is the tuple of arguments to the function.
    players.append(Player(conn))
    #lock = Lock()
    Thread(group=None, target=clientthread, name=None,
           args=(conn, players[-1].id_c)).start()


s.close()