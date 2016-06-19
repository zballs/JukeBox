import "BaseContracts.sol";

// Artist

contract Artist is JukeboxEnabled {
    
    mapping(bytes32 => address) public albums;
    mapping(bytes32 => address) public songs;
    
    function album(bytes32 name, address albumAddr) returns (bool) {
        if (!isJukebox()) return false;
        if (albums[name] != 0x0) return false;
        if (name == 0x0) return false;
        albums[name] = albumAddr;
        return true;
    }
    
    function song(bytes32 name, address songAddr) returns (bool) {
        if (!isJukebox()) return false;
        if (songs[name] != 0x0) return false;
        if (name== 0x0) return false;
        songs[name] = songAddr;
        return true;
    }

    function dropAlbum(bytes32 name) returns (bool) {
        if (!isJukebox()) return false;
        address albumAddr = albums[name];
        if (albumAddr == 0x0) return false;
        albums[name] = 0x0;
        return true;
    }

    function dropSong(bytes32 name) returns (bool) {
        if (!isJukebox()) return false;
        address songAddr = songs[name];
        if (songAddr == 0x0) return false;
        songs[name] = 0x0;
        return true;
    }
}

// Album

contract Album is ArtistEnabled {
    
    mapping(bytes32 => address) public songs;
    
    function song(bytes32 name, address songAddr) returns (bool) {
        if (!isJukebox()) return false;
        if (songs[name] != 0x0) return false;
        if (name == 0x0) return false;
        songs[name] = songAddr;
        return true; 
    }

    function dropSong(bytes32 name) returns (bool) {
        if (!isJukebox()) return false;
        address songAddr = songs[name];
        if (songAddr == 0x0) return false;
        songs[name] = songAddr;
        return true;
    }
}

// Song 

contract Song is AlbumEnabled {
    
}