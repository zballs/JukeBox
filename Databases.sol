import "BaseContracts.sol";
import "Managers.sol";

// Action Database

contract ActionDb is ActionManagerEnabled {
    mapping (bytes32 => address) public actions;
    function setContractManager(address addr) returns (bool) {
        super.setContractManager(addr);
        var add_action = new AddAction();
        bool contract_manager_set = ContractManagerEnabled(add_action).setContractManager(cm);
        if (!contract_manager_set) return false;
        actions["addaction"] = address(add_action);
    }
    function add(bytes32 name, address addr) returns (bool) {
        if (!isActionManager()) return false;
        bool contract_manager_set = ContractManagerEnabled(addr).setContractManager(cm);
        if (!contract_manager_set) return false;
        actions[name] = addr;
        return true;
    }
    function remove(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        if (actions[name] == 0x0) return false;
        actions[name] = 0x0;
        return true;
    }
}

// Artist Database

contract ArtistDb is JukeboxEnabled {
    mapping(address => address) public artists;
    
    function add(address artistAddr) returns (bool) {
        if (!isJukebox()) return false;
        if (artistAddr == 0x0) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        address artist_address = artists[caller];
        if (artist_address != 0x0) return false;
        artists[caller] = artistAddr; 
        return true;
    }
    
    function remove(address artistAddr) returns (bool) {
        if (!isJukebox()) return false;
        if (artistAddr == 0x0) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        address artist_address = artists[caller];
        if (artist_address != artistAddr) return false;
        artists[caller] = 0x0;
        return true;
    }
    
    function check(address artistAddr) returns (bool) {
        if (artistAddr == 0x0) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        address caller = ActionManager(action_manager).caller();
        address artist_address = artists[caller];
        if (artist_address != artistAddr) return false;
        return true;
    }
}