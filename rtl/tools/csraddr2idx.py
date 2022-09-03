def addr2bin(addr):
    arr=[]
    for i in range(12):
        arr.append((addr >> i) & 0x1)
    return arr

############################################################
mutex_set = set()

def addr2idx(csr_addr):
    csr_addr = addr2bin(csr_addr)
    csr_addr = (csr_addr[10], (csr_addr[4] ^ csr_addr[2]), csr_addr[1], csr_addr[0])

    valstr=""
    for bit in csr_addr:
        valstr+=('%d' % bit)

    if valstr in mutex_set:
        valstr += "\033[91mDUP\033[m"
    else:
        mutex_set.add(valstr)
    return valstr

print("CSR_IDX_MSTATUS = 4'b" + addr2idx(0x300) + ",")
print("CSR_IDX_MEPC    = 4'b" + addr2idx(0x341) + ",")
print("CSR_IDX_MCAUSE  = 4'b" + addr2idx(0x342) + ",")
print("CSR_IDX_MTVAL   = 4'b" + addr2idx(0x343) + ",")
print("CSR_IDX_MIP     = 4'b" + addr2idx(0x344) + ",")
print("CSR_IDX_MTVEC   = 4'b" + addr2idx(0x305) + ",")
print("CSR_IDX_TDATA1  = 4'b" + addr2idx(0x7a1) + ",")
print("CSR_IDX_TDATA2  = 4'b" + addr2idx(0x7a2) + ",")
print("CSR_IDX_DCSR    = 4'b" + addr2idx(0x7b0) + ",")
print("CSR_IDX_DPC     = 4'b" + addr2idx(0x7b1) + ",")
