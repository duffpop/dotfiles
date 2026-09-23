function flushdns --description 'Flushes a macOS DNS cache'
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
end
