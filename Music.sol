import "BaseContracts.sol";

contract Artist is JukeboxEnabled {
    
    mapping(bytes32 => Album) albums;
    mapping(bytes32 => Song) songs;
    
    function album(bytes32 title, Album album) returns (bool) {
        if (!isJukebox()) return false;
        if (address(albums[title]) != 0x0) return false;
        if (title == 0x0) return false;
        albums[title] = album;
        return true;
    }
    
    function song(bytes32 title, Song song) returns (bool) {
        if (!isJukebox()) return false;
        if (address(songs[title]) != 0x0) return false;
        if (title == 0x0) return false;
        songs[title] = song;
        return true;
    } 
}

contract Album is ArtistEnabled {
    
    mapping(bytes32 => Song) songs;
    
    function song(bytes32 title, Song song) returns (bool) {
        if (!isJukebox()) return false;
        if (address(songs[title]) != 0x0) return false;
        if (title == 0x0) return false;
        songs[title] = song;
        return true; 
    }
}

contract Song is AlbumEnabled {
    
}