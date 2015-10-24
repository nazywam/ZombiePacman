import socket
import sys
from threading import *
import random

HOST = ''
PORT = 6767 

players = []
joined_flag = len(players)
started_flag = False
required_players = 2
map_no = random.randint(1, 9)
map_data_tmp = []
map_data = []
lock = Lock()

with open('assets/data/level'+str(map_no)+'.txt', 'r') as f:
    map_data_tmp=(f.read().split('\n'))
    for i in map_data_tmp:
        map_data.append(i.split(','))

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
        global players, joined_flag, required_players
        Player.ready_players += 1
        joined_flag = len(players)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Socket created'

try:
    s.bind((HOST, PORT))
except socket.error as msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()
print 'Socket bind complete'
s.listen(10)
print 'Socket now listening'


def clientthread(conn, id_c):
    global players, joined_flag, required_players, map_no
    global lock

    data = conn.recv(1024).strip()
    print data
    if data == 'READY':
        players[id_c].set_ready()
    while True:
        if joined_flag:
#            print 'joined_flag', joined_flag
            print("lock 1 acquired ", id_c)
            lock.acquire()
            try:
                joined_flag -= 1
                print str(Player.ready_players) + '/' + str(required_players)+'\n'
                conn.sendall(str(Player.ready_players) + '/' + str(required_players)+'\n')
            finally:
                print("lock 1 released ", id_c)
                lock.release()
            if Player.ready_players >= required_players and not started_flag:
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

while 1:
    conn, addr = s.accept()
    print 'Connected with ' + addr[0] + ':' + str(addr[1])

    players.append(Player(conn))

    Thread(group=None, target=clientthread, name=None,
           args=(conn, players[-1].id_c)).start()


s.close()