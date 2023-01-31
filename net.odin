package net

import "core:c"
import "core:sys/windows"

SOCKET :: distinct uintptr

INVALID_SOCKET :: ~SOCKET(0)

AF_INET: c.int : 2
SOCK_STREAM: c.int : 1

in_addr :: struct {
    s_addr: u32,
}

sockaddr  :: struct {
    sa_family: c.ushort,
    sa_data:   [14]byte,
}

sockaddr_in :: struct {
    sin_family: c.ushort,
    sin_port: c.ushort,
    sin_addr: in_addr,
    sin_zero: [8]c.char,
}

SOCKADDR :: struct {
    sa_family: c.ushort,
    sa_data: [14]c.char,
}

hostent :: struct {
    h_name: cstring,
    h_aliases: [^]cstring,
    h_addrtype: c.short,
    h_length: c.short,
    h_addr_list: [^]in_addr,
}

when ODIN_OS == .Linux {
    ADDRINFOA :: struct {
        ai_flags: c.int,
        ai_family: c.int,
        ai_socktype: c.int,
        ai_protocol: c.int,
        ai_addrlen: c.size_t,
        ai_addr: ^SOCKADDR,
        ai_canonname: ^c.char,
        ai_next: ^ADDRINFOA,
    }
    
    foreign import libc "system:c"
    foreign libc {
        socket :: proc(af: c.int, type: c.int, protocol: c.int) -> SOCKET ---
        read :: proc(socket: SOCKET, buf: rawptr, len: c.int, flags: c.int) -> c.int ---
        write :: proc(socket: SOCKET, buf: rawptr, len: c.int, flags: c.int) -> c.int ---
        connect :: proc(socket: SOCKET, address: ^SOCKADDR, len: c.int) -> c.int ---

        inet_addr :: proc(cstring) -> c.ulong ---
        htons :: proc(c.ushort) -> c.ushort ---

        gethostbyname :: proc(cstring) -> ^hostent ---
        inet_ntoa::proc(in_addr) -> cstring ---

        getaddrinfo :: proc(
            node: cstring,
            service: cstring,
            hints: ^ADDRINFOA,
            res: ^^ADDRINFOA,
        ) -> c.int ---
    }

} else when ODIN_OS == .Windows {
    import "core:sys/windows"

    ADDRINFOA :: struct {
        ai_flags: c.int,
        ai_family: c.int,
        ai_socktype: c.int,
        ai_protocol: c.int,
        ai_addrlen: c.size_t,
        ai_canonname: ^c.char,
        ai_addr: ^SOCKADDR,
        ai_next: ^ADDRINFOA,
    }

    read :: windows.recv
    write :: windows.send
    foreign import ws "system:Ws2_32.lib"
    foreign ws {
        gethostbyname :: proc(cstring) -> ^hostent ---
    }
}