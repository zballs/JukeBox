import "BaseContracs.sol";

contract Action is ActionManagerEnabled, Validee {
    uint8 public permission;
    
    function setPermission(uint8 permVal) returns (bool) {
        if (!validate()) return false;
        permission = permVal;
        return true;
    }
}

contract AddAction is Action {
    function execute(bytes32 name, address addr) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address actionDb = cp.contracts("actiondb");
        if (actionDb == 0x0) return false;
        return ActionDb(actionDb).addAction(name,addr);
    }
}

contract RemoveAction is Action {
    function execute(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address actionDb = cp.contracts("actiondb");
        if (actionDb == 0x0) return false;
        if (name == "addaction") return false;
        return ActionDb(actionDb).removeAction(name);
    }
}

contract LockActions is Action {
    function execute() returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        if (action_manager == 0x0) return false;
        return ActionManager(action_manager).lock();
    }
}

contract UnlockActions is Action {
    function execute() returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address action_manager = cp.contracts("actions");
        if (action_manager == 0x0) return false;
        return ActionManager(action_manager).unlock();
    }
}

contract AddContract is Action {
    function execute(bytes32 name, address addr) returns (bool) {
        if (!isActionManager()) return false;
        ContractManager contract_manager = ContractManager(cm);
        return contract_manager.addContract(name,addr);
    }
}

contract RemoveContract is Action {
    function execute(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        ContractManager contract_manager = ContractManager(cm);
        return contract_manager.removeContract(name);
    }
}

contract SetUserPermissions is Action {
    function execute(address addr, uint8 perm) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address perms = cp.contracts("perms");
        if (perms == 0x0) return false;
        return Permissions(perms).setPermission(addr,perm);
    }
}

contract SetActionPermissions is Action {
    function execute(bytes32 name, uint8 perm) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address actionDb = cp.contracts("actiondb");
        if (actionDb == 0x0) return false;
        address actn = ActionDb(actionDb).actions(name);
        if (actn == 0x0) return false;
        return Action(actn).setPermission(perm);
    }
}

// Artist, Album, Song add

contract AddArtist is Action {
    function execute(bytes32 name, bytes32 genre) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address jukebox = cp.contracts("jukebox");
        if (jukebox == 0x0) return false;
        return Adder(jukebox).addArtist(name,genre);
    }
}

contract AddAlbum is Action {
    function execute(bytes32 title, bytes32 genre, address artist, uint8 price) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address jukebox = cp.contracts("jukebox");
        if (jukebox == 0x0) return false;
        return Adder(jukebox).addAlbum(title,genre,artist,price);
    }
}

contract AddSong is Action {
    function execute(bytes32 title, bytes32 genre, address album_or_artist, uint8 price) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address jukebox = cp.contracts("jukebox");
        if (jukebox == 0x0) return false;
        return Adder(jukebox).addSong(title,genre,album_or_artist,price);
    }
}

// Album, Song purchase
contract Purchase is Action {
    function execute(address song_or_album) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address jukebox = cp.contracts("jukebox");
        if (jukebox == 0x0) return false;
        bool success = Purchaser(jukebox).purchase(song_or_album);
    } 
}

// Album, Song play
contract Play is Action {
    function execute(address song_or_album) returns (bool) {
        if (!isActionManager()) return false;
        ContractProvider cp = ContractProvider(cm);
        address jukebox = cp.contracts("jukebox");
        if (jukebox == 0x0) return false;
        return Player(jukebox).play(song_or_album);
    }
}