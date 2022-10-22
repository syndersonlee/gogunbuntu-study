#!/usr/bin/perl

use Socket;
use Carp;
use FileHandle;

$port = (@ARGV ? $ARGV[0] : 8080);

$proto = getprotobyname('tcp');
socket(S, PF_INET, SOCK_STREAM, $proto) || die;
setsockopt(S, SOL_SOCKET, SO_REUSEADDR, pack("l", 1)) || die;
bind(S, sockaddr_in($port, INADDR_ANY)) || die;
listen(S, SOMAXCONN) || die;

printf(" <<<Type-O-Servce Accepting on Port %d>>\n\n", $port);

while(1) {
    $cport_caddr = accept(C,S);
    ($cport,$caddr) = sockaddr_in($cport_caddr);
    C->autoflush(1);

    $cname = gethostbyaddr($caddr, AF_INET);
    printf(" <<<Request From '%s'>>>\n",$cname);

    while($line = <C>) {
        print $line;
        if($line =~ /^\r/) { last; }
    }

    printf(" <<<Type Response Followed by '.'>>>\n");

    while ($line = <STDIN>) {
        $line =~ s/\r//;
        $line =~ s/]n//;
        if ($line =~ /^\./) { last; }
        print C $line . "\r\n";
    }

    close(C);
}