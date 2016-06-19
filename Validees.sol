import "BaseContracts.sol";
import "Music.sol";
import "Managers.sol";
import "Databases.sol";

// Users 

contract Users is Validee {
    mapping(address => bytes32) internal users;
    
    function register(bytes32 name) returns (bool) {
        if (!validate()) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        if (action_manager == 0x0) return false;
        address caller = ActionManager(action_manager).caller();
        if (caller == 0x0) return false;
        if (users[caller] != "") return false;
        if (name == "") return false;
        users[caller] = name;
        return true;
    }
    
    function unregister(bytes32 name) returns (bool) {
        if (!validate()) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        if (action_manager == 0x0) return false;
        address caller = ActionManager(action_manager).caller();
        if (caller == 0x0) return false;
        if (users[caller] == "") return false;
        if (name == "") return false;
        delete users[caller];
        return true;
    }
    
    function check(address addr) constant returns (bool) {
        if (!validate()) return false;
        if (addr == 0x0) return false;
        if (users[addr] != "") return true;
        return false;
    }
} 

// Jukebox

contract Jukebox is Validee {
    
    function addArtist(bytes32 name, bytes32 genre) returns (bool) {
        if (!validate()) return false;
        Artist artist = new Artist();
        address artistAddr = address(artist);
        address artistDb = ContractProvider(cm).contracts("artistdb");
        bool contract_manager_set = ContractManagerEnabled(artistAddr).setContractManager(cm);
        if (!contract_manager_set) return false;
        bool name_set = JbxInterface(artistAddr).setName(name);
        if (!name_set) return false;
        bool genre_set = JbxInterface(artistAddr).setGenre(genre);
        if (!genre_set) return false;
        bool added = ArtistDb(artistDb).add(artistAddr);
        if (!added) delete artist; return false;
        return true;
    }
    
    function addAlbum(bytes32 name, bytes32 genre, uint8 price) returns (bool) {
        if (!validate()) return false;
        Album album = new Album();
        address albumAddr = address(album);
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        address artistDb = ContractProvider(cm).contracts("artistdb");
        address artistAddr = ArtistDb(artistDb).artists(caller);
        bool contract_manager_set = ContractManagerEnabled(albumAddr).setContractManager(cm);
        if (!contract_manager_set) return false;
        bool name_set = JbxInterface(albumAddr).setName(name);
        if (!name_set) delete album; return false;
        bool genre_set = JbxInterface(albumAddr).setGenre(genre);
        if (!genre_set) delete album; return false;
        bool price_set = JbxInterface(albumAddr).setPrice(price);
        if (!price_set) delete album; return false;
        bool artist_set = JbxInterface(albumAddr).setArtist(artistAddr);
        if (!artist_set) delete album; return false;
        bool repertoire = JbxInterface(artistAddr).album(name,album);
        if (!repertoire) delete album; return false;
        return true;
    }
    
    function addSong(bytes32 name, bytes32 genre, uint8 price, address albumAddr) returns (bool) {
        if (!validate()) return false;
        Song song = new Song();
        address songAddr = address(song);
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        address artistDb = ContractProvider(cm).contracts("artistdb");
        address artistAddr = ArtistDb(artistDb).artists(caller);
        bool contract_manager_set = ContractManagerEnabled(songAddr).setContractManager(cm);
        if (!contract_manager_set) return false;
        bool name_set = JbxInterface(songAddr).setName(name);
        if (!name_set) delete song; return false;
        bool genre_set = JbxInterface(songAddr).setGenre(genre);
        if (!genre_set) delete song; return false;
        bool price_set = JbxInterface(songAddr).setPrice(price);
        if (!price_set) delete song; return false;
        bool artist_set = JbxInterface(songAddr).setArtist(artistAddr);
        if (!artist_set) delete song; return false;
        bool repertoire = JbxInterface(artistAddr).song(name,song);
        if (!repertoire) delete song; return false;
        bool addToAlbum = (albumAddr != 0x0);
        if (addToAlbum) {
            bool album_set = JbxInterface(albumAddr).song(name,song);
            if (!album_set) return false;
        }
        return true;
    }

    function removeArtist(address artistAddr) returns (bool) {
        if (!validate()) return false;
        address artistDb = ContractProvider(cm).contracts("artistdb");
        bool removedFromDb = ArtistDb(artistDb).remove(artistAddr);
        if (!removedFromDb) return false;
        JbxInterface(artistAddr).remove();
        return true;
    }

    function removeAlbum(address albumAddr) returns (bool) {
        if (!validate()) return false;
        address artistAddr = JbxInterface(albumAddr).artist();
        address artistDb = ContractProvider(cm).contracts("artistdb");
        bytes32 name = JbxInterface(albumAddr).name();
        bool callerIsArtist = ArtistDb(artistDb).check(artistAddr);
        if (!callerIsArtist) return false;
        bool dropped = JbxInterface(artistAddr).dropAlbum(name);
        if (!dropped) return false;
        JbxInterface(albumAddr).remove();
        return true;
    }

    function removeSong(address songAddr, bool justFromAlbum) returns (bool) {
        if (!validate()) return false;
        address artistAddr = JbxInterface(songAddr).artist();
        address albumAddr = JbxInterface(songAddr).album();
        address artistDb = ContractProvider(cm).contracts("artistdb");
        bytes32 name = JbxInterface(songAddr).name();
        bool callerIsArtist = ArtistDb(artistDb).check(artistAddr);
        if (!callerIsArtist) return false;
        bool dropped = JbxInterface(albumAddr).dropSong(name);
        if (!justFromAlbum) dropped = dropped && JbxInterface(artistAddr).dropSong(name);
        if (!dropped) return false;
        JbxInterface(songAddr).remove();
        return true;
    }
    
    function access(address addr) returns (bool) {
        if (!validate()) return false;
        address artistAddr = JbxInterface(addr).artist();
        address artistDb = ContractProvider(cm).contracts("artistdb");
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        uint8 price = JbxInterface(addr).price();
        bool accessorNotArtist = !ArtistDb(artistDb).check(artistAddr);
        if (!accessorNotArtist) return false;
        bool success = JbxInterface(addr).access(caller);
        if (!success) return false;
        artistAddr.send(price);
        return true;
    }
    
    function get(address addr) returns (bool) {
        if (!validate()) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        bool success = JbxInterface(addr).get(caller);
        if (!success) return false;
        return true;
    }
}

// Permissions

contract Permissions is Validee {
    mapping(address => uint8) public perms;
    
    function setpPerm(address addr, uint8 perm) returns (bool) {
        if (!validate()) return false;
        perms[addr] = perm;
    }
}