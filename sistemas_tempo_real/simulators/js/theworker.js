
var i = 0;


function scan_cycle() {
    

    i = i + 1;
    postMessage(i );
    //aaaaaa
    //if (is_running)
    setTimeout("scan_cycle()", 1);
}

scan_cycle();