import "BaseContracts.sol";

contract Jukebox is Validee {
    mapping(bytes32 => Artist) public artists;
    
    function addArtist(bytes32 name, bytes32 genre, uint8 price) returns (bool) {
        if (!validate()) return false;
        address artistAddr = address(artists[name]);
        if (artistAddr != 0x0) return false;
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        address caller = ActionManager(action_manager).returnCaller();
        Artist artist = new Artist();
        artistAddr = address(artist);
        bool added = Abstract(artistAddr).add(name,genre);
        if (!added) delete artist; return false;
        bool set = Abstract(artistAddr).setId(caller) && Abstract(artistAddr).setJbx();
        if (!set) delete artist; return false;
        artists[name] = artist;
        return true;
    }
    
    function addAlbum(bytes32 title, bytes32 genre, address artist, uint8 price) returns (bool) {
        if (!validate()) return false;
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        address caller = ActionManager(action_manager).returnCaller();
        if (!Abstract(artist).validId(caller)) return false;
        Album album = new Album();
        address albumAddr = address(album);
        bool added = Abstract(albumAddr).add(title,genre);
        if (!added) delete album; return false;
        bool set = Abstract(albumAddr).setId(caller) && Abstract(albumAddr).setArt(artist) && Abstract(albumAddr).setJbx() && Abstract(albumAddr).setPrice(price);
        if (!set) delete album; return false;
        bool repertoire = Abstract(artist).album(title,album);
        if (!repertoire) delete album; return false;
        return true;
    }
    
    function addSong(bytes32 title, bytes32 genre, address album_or_artist, uint8 price) returns (bool) {
        if (!validate()) return false;
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        address caller = ActionManager(action_manager).returnCaller();
        if (!Abstract(album_or_artist).validId(caller)) return false;
        address artist = Abstract(album_or_artist).returnArt();
        if (artist != 0x0) address album = album_or_artist;
        else artist = album_or_artist;
        Song song = new Song();
        address songAddr = address(song);
        bool added = Abstract(songAddr).add(title,genre);
        if (!added) delete song; return false;
        bool set = Abstract(songAddr).setId(caller) && Abstract(songAddr).setArt(artist) && Abstract(songAddr).setJbx() && Abstract(songAddr).setPrice(price);
        if (album != 0x0) set = set && Abstract(songAddr).setAlb(album);
        if (!set) delete song; return false;
        bool repertoire = Abstract(artist).song(title,song);
        if (album != 0x0) repertoire = repertoire && Abstract(album).song(title,song);
        if (!repertoire) delete song; return false;
        return true;
    } 
    
    function play(address song_or_album) returns (bool) {
        if (!validate()) return false;
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        address caller = ActionManager(action_manager).returnCaller();
        bool success = Abstract(song_or_album).play(caller);
        if (!success) return false;
        return true;
    }
    
    function purchase(address song_or_album) returns (bool) {
        if (!validate()) return false; 
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        address caller = ActionManager(action_manager).returnCaller();
        bool success = Abstract(song_or_album).purchase(caller);
        if (!success) return false;
        return true;
    }
}

contract Permissions is Validee {
    mapping(address => uint8) public perms;
    
    function setPermission(address addr, uint8 perm) returns (bool) {
        if (!validate()) return false;
        perms[addr] = perm;
    }
}