import "BaseContracts.sol";
import "Managers.sol";
import "Databases.sol";

// Action 
contract Action is ActionManagerEnabled, Validee {
    uint8 public perm;
    
    function setPerm(uint8 permVal) returns (bool) {
        if (!validate()) return false;
        perm = permVal;
        return true;
    }
}

// Action-related actions 
contract AddAction is Action {
    function execute(bytes32 name, address addr) returns (bool) {
        if (!isActionManager()) return false;
        address actionDb = ContractProvider(cm).contracts("actiondb");
        if (actionDb == 0x0) return false;
        return ActionDb(actionDb).add(name,addr);
    }
}

contract RemoveAction is Action {
    function execute(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        address actionDb = ContractProvider(cm).contracts("actiondb");
        if (actionDb == 0x0) return false;
        if (name == "addaction") return false;
        return ActionDb(actionDb).remove(name);
    }
}

contract LockActions is Action {
    function execute() returns (bool) {
        if (!isActionManager()) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        if (action_manager == 0x0) return false;
        return ActionManager(action_manager).lock();
    }
}

contract UnlockActions is Action {
    function execute() returns (bool) {
        if (!isActionManager()) return false;
        address action_manager = ContractProvider(cm).contracts("actions");
        if (action_manager == 0x0) return false;
        return ActionManager(action_manager).unlock();
    }
}

contract SetActionPermissions is Action {
    function execute(bytes32 name, uint8 perm) returns (bool) {
        if (!isActionManager()) return false;
        address actionDb = ContractProvider(cm).contracts("actiondb");
        if (actionDb == 0x0) return false;
        address actn = ActionDb(actionDb).actions(name);
        if (actn == 0x0) return false;
        return Permissioner(actn).setPerm(perm);
    }
}

// Contract-related actions
contract AddContract is Action {
    function execute(bytes32 name, address addr) returns (bool) {
        if (!isActionManager()) return false;
        return ContractManager(cm).add(name,addr);
    }
}

contract RemoveContract is Action {
    function execute(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        return ContractManager(cm).remove(name);
    }
}

// User-related actions
contract RegisterUser is Action {
    function execute(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        address users = ContractProvider(cm).contracts("users");
        if (users == 0x0) return false;
        return Registry(users).register(name);
    }
}

contract UnregisterUser is Action {
    function execute(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        address users = ContractProvider(cm).contracts("users");
        if (users == 0x0) return false;
        return Registry(users).unregister(name);
    }
}

contract SetUserPermissions is Action {
    function execute(address addr, uint8 perm) returns (bool) {
        if (!isActionManager()) return false;
        address users = ContractProvider(cm).contracts("users");
        if (users == 0x0) return false;
        if (!Registry(users).check(addr)) return false;
        address permissions = ContractProvider(cm).contracts("permissions");
        if (permissions == 0x0) return false;
        return Permissioner(permissions).setPerm(addr,perm);
    }
}

// User action
contract UserAction is Action, UserEnabled {
    function UserCheck() returns (bool) {
        if (!isActionManager()) return false;
        address caller = ActionManager(msg.sender).caller();
        if (!isUser(caller)) return false;
        return true;
    }
}

// Artist, Album, Song adds 
contract AddArtist is UserAction {
    function execute(bytes32 name, bytes32 genre) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).addArtist(name,genre);
    }
}

contract AddAlbum is UserAction {
    function execute(bytes32 name, bytes32 genre, uint8 price) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).addAlbum(name,genre,price);
    }
}

contract AddSong is UserAction {
    function execute(bytes32 name, bytes32 genre, uint8 price, address albumAddr) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).addSong(name,genre,price,albumAddr);
    }
}

// Artist, Album, Song removals
contract RemoveArtist is UserAction {
    function execute(address artistAddr) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).removeArtist(artistAddr);
    }
}

contract RemoveAlbum is UserAction {
    function execute(address albumAddr) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).removeAlbum(albumAddr);
    }
}

contract RemoveSong is UserAction {
    function execute(address songAddr, bool justFromAlbum) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).removeSong(songAddr,justFromAlbum);
    }
}


// Content distribution
contract AccessContent is UserAction {
    function execute(address addr) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        bool success = UserInterface(jukebox).access(addr);
        return true;
    } 
}

contract GetContent is UserAction {
    function execute(address addr) returns (bool) {
        if (!UserCheck()) return false;
        address jukebox = ContractProvider(cm).contracts("jukebox");
        if (jukebox == 0x0) return false;
        return UserInterface(jukebox).get(addr);
    }
}


