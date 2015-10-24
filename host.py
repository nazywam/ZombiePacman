import socket
import random
import sys

HOST = '10.10.99.85'
PORT = 6675
BUFF_SIZE = 1024

REQUIRED_PLAYERS = 2


def get_map_no(m):
    return random.randint(1, m)


def get_start_pos(m, w, h):
    """
        m -> map_no
        w -> max_width
        h -> max_height
    """
    x = random.randint(1, w)
    y = random.randint(1, h)
    return (x, y)


def get_all_start_pos(m, w, h, n):
    """
    get start position for all connected players
        m -> map_no
        w -> max_width
        h -> max_height
        n -> number of connected players
    """
    res = ''
    for i in xrange(n):
        x = get_start_pos(m, w, h)
        res += str(x[0]) + 'x' + str(x[1]) + ':'
    res = res[:-1]  # trimming last colon
    return res


def parse_directions(dire):
    res = ''
    for i in dire:
        print res
        res += str(i).strip() + ':'
    res = res[:-1]
    res += '\n'
    return res


def com_with_clients():
    global connections
    print connections
    map_no = get_map_no(10)
    for i, c in enumerate(connections):
        if c[0].recv(BUFF_SIZE).strip() != 'READY':
            c[0].sendall('BLAD INICJALIZACJI POLACZENIA (nie ready?)')
            print c, 'BLAD INICJALIZACJI POLACZENIA'
            connections.remove(c)
            c[0].close()
    st_pos = get_all_start_pos(map_no, 15, 15, len(connections))
    directions = [0 for i in xrange(len(connections))]
    for i, c in enumerate(connections):
        c[0].sendall('START\n')
        connections[i][0].sendall(str(i) + ':' + str(map_no) + '\n')
        c[0].sendall(st_pos + '\n')
    while True:
        for i, c in enumerate(connections):
            directions[i] = c[0].recv(BUFF_SIZE)
        dire=parse_directions(directions)
        print dire
        for i, c in enumerate(connections):
            c[0].sendall(dire)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    s.bind((HOST, PORT))
except socket.error as msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()
s.listen(10)

connections = []
while 1:
    #conn,addr = s.accept()
    # if conn.recv(BUFF_SIZE) == 'READY':
    # connections.append((conn,addr))
    # s.accept()
    connections.append(s.accept())
    if len(connections) >= REQUIRED_PLAYERS:
        com_with_clients()
s.close()
