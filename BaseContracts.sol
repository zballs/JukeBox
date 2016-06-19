import "PureInterfaces.sol";

// Base Contracts

contract ContractManagerEnabled {
    address cm;
    
    function setContractManager(address addr) returns (bool) {
        if (cm != 0x0 && cm != addr) return false;
        cm = addr;
        return true;
    }
    
    function destroy() {
        if (msg.sender == cm) suicide(cm);
    }
}

contract ActionManagerEnabled is ContractManagerEnabled {
    function isActionManager() internal constant returns (bool) {
        if (cm != 0x0) {
            address action_manager = ContractProvider(cm).contracts("actions");
            if (action_manager == msg.sender) return true;
        }
        return false;
    }
}

contract UserEnabled is ContractManagerEnabled {
    
    function isUser(address addr) internal constant returns (bool) {
        if (cm != 0x0) {
            address users = ContractProvider(cm).contracts("users");
            return Registry(users).check(addr);
        }
        return false;
        
    }
}

contract JukeboxEnabled is ContractManagerEnabled {
    bytes32 public name;
    bytes32 public genre;
    
    function isJukebox() internal constant returns (bool) {
        if (cm != 0x0) {
            address jukebox = ContractProvider(cm).contracts("jukebox");
            if (jukebox == msg.sender) return true;
        }
        return false;
    }
    
    function setName(bytes32 _name) internal returns (bool) {
        if (name != "") return false;
        if (_name == "") return false;
        name = _name;
        return true;
    }
    
    function setGenre(bytes32 _genre) internal returns (bool) {
        if (genre != "") return false;
        if (_genre == "") return false;
        genre = _genre;
        return true;
    } 

    function remove() {
        if (isJukebox()) suicide(msg.sender);
    }
}

contract ArtistEnabled is JukeboxEnabled {
    address public artistAddr;
    uint8 public price;
    
    mapping(address => bool) internal _access;
    
    function setPrice(uint8 _price) internal returns (bool) {
        if (price != 0) return false;
        if (!(_price > 0)) return false; 
        price = _price;
        return true;
    }
    
    function setArtist(address _artistAddr) internal returns (bool) {
        if (artistAddr != 0x0) return false;
        if (_artistAddr == 0x0) return false;
        artistAddr = _artistAddr;
        return true;
    }
    
    function access(address accessor) internal returns (bool) {
        if (!isJukebox()) return false;
        if (!(price > 0)) return false;
        if (_access[accessor]) return false;
        _access[accessor] = true;
        return true;
    }
    
    function get(address getter) internal returns (bool) {
        if (!isJukebox()) return false;
        if (!_access[getter]) return false;
        // retrieve content from C3D-P2P network
        // send content to listener
        return true;
    }
}

contract AlbumEnabled is ArtistEnabled {
    address public albumAddr; 
    
    function setAlbum(address _albumAddr) internal returns (bool) {
        if (albumAddr != 0x0) return false;
        if (_albumAddr == 0x0) return false;
        albumAddr == _albumAddr;
        return true;
    }
}

contract Validee is ContractManagerEnabled {
    function validate() internal constant returns (bool) {
        if (cm != 0x0) {
            address action_manager = ContractProvider(cm).contracts("actions");
            if (action_manager == 0x0) return false;
            return Validator(action_manager).validate(msg.sender);
        }
        return false;
    }
}