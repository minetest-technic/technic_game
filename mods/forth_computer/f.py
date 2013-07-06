f = open('forth.fth','r')
lf = f.readlines()
f.close()
df = {}


def setmemory(addr, value):
    memory[addr] = value&0xff
    memory[addr+1] = (value>>8)&0xff

def to_int(x):
    if x[:2]=="0x":
        try:
            a=int(x[2:],16)
            return a
        except:
            return None
    try:
        a=int(x)
        return a
    except:
        return None

def header(name):
    global here
    global latest
    memory[here] = 0
    here += 1
    for c in name.strip():
        memory[here] = ord(c)
        here += 1
    setmemory(here, latest)
    here += 2
    memory[here] = len(name)
    here += 1
    latest = here
    df[name] = here

def compile_constant(name, value):
    value=to_int(value)
    global here
    header(name)
    memory[here] = 77
    here += 1
    setmemory(here, value)
    here += 2
    memory[here] = 33
    here += 1
    memory[here] = 41
    here += 1

"""ITABLE = {
"IPOP":0x28,
"NXT":0x29,
"CALL":0x2a,
"CRX":0x2b,

"TSX":0x08,
"TRX":0x09,
"TPX":0x0a,
"TIX":0x0b,

"BRK":0x00,

"RPHX":0x01,
"RPHY":0x02,
"RPHZ":0x03,
"RPX":0x10,
"RPLX":0x11,
"RPLY":0x12,
"RPLZ":0x13,

"PSX":0x20,
"PHX":0x21,
"PHY":0x22,
"PHZ":0x23,
"SPX":0x30,
"PLX":0x31,
"PLY":0x32,
"PLZ":0x33,

"RXX":0x04,
"RXY":0x05,
"RYX":0x06,
"RYY":0x07,

"CRXX":0x14,
"CRXY":0x15,
"CRYX":0x16,
"CRYY":0x17,

"WXY":0x25,
"WYX":0x26,
"CWXY":0x35,
"CWYX":0x36,

}"""


def compile_assembly(name, l):
    global here
    header(name)
    for inst in l:
        memory[here] = to_int(inst)
        #memory[here] = ITABLE[inst]
        here += 1

squit = []
def compile_def(name, l, immed=False):
    global here
    global squit
    header(name)
    if immed:
        memory[here-1] |= 128
    memory[here] = 42
    here += 1
    i = 0
    stack = []
    #print(name)
    while i<len(l):
        #print(stack)
        word = l[i]
        i += 1
        if to_int(word)!=None:
            setmemory(here, df["(lit)"])
            here += 2
            setmemory(here, to_int(word))
            here += 2
        elif word == "POSTPONE":
            nw = l[i]
            i += 1
            setmemory(here, df[nw])
            here += 2
        elif word == "LITERAL":
            setmemory(here, df["(lit)"])
            here += 2
            setmemory(here, stack.pop())
            here += 2
        elif word == "[']":
            setmemory(here, df["(lit)"])
            here += 2
            nw = l[i]
            i += 1
            setmemory(here, df[nw])
            here += 2
        elif word == "[COMPILE]":
            setmemory(here, df["(lit)"])
            here += 2
            nw = l[i]
            i += 1
            setmemory(here, df[nw])
            here += 2
            setmemory(here, df[","])
            here += 2
        elif word == "IF":
            setmemory(here, df["(0branch)"])
            here += 2
            stack.append(here)
            setmemory(here, 0)
            here += 2
        elif word == "ELSE":
            setmemory(here, df["(branch)"])
            here += 2
            n = stack.pop()
            stack.append(here)
            setmemory(here, 0)
            here += 2
            setmemory(n, here)
        elif word == "THEN":
            setmemory(stack.pop(), here)
        elif word == "BEGIN":
            stack.append(here)
        elif word == "UNTIL":
            setmemory(here, df["(0branch)"])
            here += 2
            setmemory(here, stack.pop())
            here += 2
        elif word == "REPEAT":
            setmemory(here, df["(branch)"])
            here += 2
            setmemory(here, stack.pop())
            here += 2
            setmemory(stack.pop(), here)
        elif word == "AGAIN":
            setmemory(here, df["(branch)"])
            here += 2
            setmemory(here, stack.pop())
            here += 2
        elif word == "WHILE":
            setmemory(here, df["(0branch)"])
            here += 2
            n = stack.pop()
            stack.append(here)
            stack.append(n)
            setmemory(here, 0)
            here += 2
        elif word == "DO":
            setmemory(here, df["(do)"])
            here += 2
            stack.append(here)
            here += 2
            stack.append(here)
        elif word == "?DO":
            setmemory(here, df["(?do)"])
            here += 2
            stack.append(here)
            here += 2
            stack.append(here)
        elif word == "LOOP":
            setmemory(here, df["(loop)"])
            here += 2
            setmemory(here, stack.pop())
            here += 2
            setmemory(stack.pop(), here)
        elif word == "QUIT":
            squit.append(here)
            here += 2
        elif word == 'S"':
            nw = l[i][:-1] #Remove trailing "
            i += 1
            setmemory(here, df["(branch)"])
            here += 2
            stack.append(here)
            here += 2
            stack.append(here)
            for c in nw:
                memory[here] = ord(c)
                here += 1
            k = stack.pop()
            setmemory(stack.pop(), here)
            setmemory(here, df["(lit)"])
            here += 2
            setmemory(here, k)
            here += 2
            setmemory(here, df["(lit)"])
            here += 2
            setmemory(here, len(nw))
            here += 2
        else:
            setmemory(here, df[word])
            here += 2
    setmemory(here, df["EXIT"])
    here += 2

memory=[0]*0x10000
here=0x404
latest=0
state="forth"
for i in lf:
    k = i.split()
    if len(k)>=1 and k[0] == "ASSEMBLER":
        state="assembler"
    elif len(k)>=1 and k[0] == "FORTH":
        state="forth"
    elif len(k)>=3 and k[1] == "CONSTANT" and k[0]!=":":
        compile_constant(k[2],k[0])
    elif len(k)>=3:
        #print(k[0])
        if k[0][0] == "\\":
            continue
        if state=="forth":
            if k[-1] == "IMMEDIATE":
                compile_def(k[1],k[2:-2],True)
            else:
                compile_def(k[1],k[2:-1])
        else:
            compile_assembly(k[1],k[2:-1])

for i in squit:
    setmemory(i, df["QUIT"])
    
memory[0x108]=10
memory[0x400]=0x4d
setmemory(0x401, df["COLD"])
memory[0x403]=0x1a
setmemory(0x10c, latest)
setmemory(0x112, here)

def getc(i):
    for key,k in df.items():
        if k==i:
            return key

f = open('computer_memory.lua','w')
f.write("function create_cptr_memory()\n\treturn {\n")
for i in range(len(memory)):
    f.write("\t\t["+str(i)+"] = "+str(memory[i])+",\n")
f.write("\t}\nend")
f.close()

