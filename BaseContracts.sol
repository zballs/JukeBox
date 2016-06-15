import "PureInterfaces.sol";

contract ContractManagerEnabled {
    address cm;
    
    function setContractManager(address addr) returns (bool) {
        if (cm != 0x0 && cm != addr) return false;
        cm = addr;
        return true;
    }
    
    function remove() {
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

contract JukeboxEnabled is ContractManagerEnabled {
    address internal id;
    address internal jbx;
    bytes32 internal name;
    bytes32 internal genre;
    
    function returnJbx() returns (address) {
        return jbx;
    }
    
    function setId(address _id) internal returns (bool) {
        if (!isJukebox()) return false;
        if (id != 0x0) return false;
        if (_id == 0x0) return false;
        return true;
    }
    
    function validId(address _id) internal constant returns (bool) {
        if (!isJukebox()) return false;
        if (id != _id) return false;
        return true;
    }
    
    function isJukebox() internal constant returns (bool) {
        if (cm != 0x0) {
            address jukebox = ContractProvider(cm).contracts("jukebox");
            if (jukebox == msg.sender) return true;
        }
        return false;
    }
    
    function setJbx() internal returns (bool) {
        if (!isJukebox()) return false;
        if (jbx != 0x0) return false;
        jbx = msg.sender;
        return true;
    }
    
    function add(bytes32 _name, bytes32 _genre) internal returns (bool) {
        if (!isJukebox()) return false;
        if (name != "" || genre != "") return false;
        if (_name == "" || _genre == "") return false;
        name = _name;
        genre = _genre;
        return true;
    } 
}

contract ArtistEnabled is JukeboxEnabled {
    address internal art;
    uint8 internal price;
    mapping(address => bool) internal access;
    bytes data;
    
    function returnArt() returns (address) {
        return art;
    }
    
    function returnPrice() returns (uint8) {
        return price;
    }
    
    function setArt(address addr) internal returns (bool) {
        if (!isJukebox()) return false;
        if (art != 0x0) return false;
        if (addr == 0x0) return false;
        art = addr;
        return true;
    }
    
    function setPrice(uint8 _price) internal returns (bool) {
        if (!isJukebox()) return false;
        if (price != 0) return false;
        if (!(_price > 0)) return false; 
        price = _price;
        return true;
    }
    
    function play(address listener) internal returns (bool) {
        if (!isJukebox()) return false;
        if (!access[listener]) return false;
        address(this).call(data);
        return true;
    }
    
    function purchase(address buyer) internal returns (bool) {
        if (!isJukebox()) return false;
        if (!(price > 0)) return false;
        if (buyer == id) return false;
        if (access[buyer]) return false;
        id.send(price);
        access[buyer] = true;
        return true;
    }
}

contract AlbumEnabled is ArtistEnabled {
    address internal alb; 
    
    function returnAlb() returns (address) {
        return alb;
    }
    
    function setAlb(address addr) internal returns (bool) {
        if (!isJukebox()) return false;
        if (alb != 0x0) return false;
        if (addr == 0x0) return false;
        alb == addr;
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