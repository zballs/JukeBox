import "BaseContracts.sol";

contract ContractManager {
    
    address owner;
    mapping(bytes32 => address) public contracts;
    
    function ContractManager() {
        owner = msg.sender;
    }
    
    function addContract(bytes32 name, address addr) returns (bool) {
        var action_manager = contracts["actions"];
        var actionDb = contracts["actiondb"];
        if (action_manager != 0x0 || actionDb == 0x0) {
            bool validated = Validator(action_manager).validate(msg.sender);
            if (!validated) return false;
        }
        ContractManagerEnabled cme = ContractManagerEnabled(addr);
        if (!cme.setContractManager(address(this))) return false;
        contracts[name] = addr;
        return true;
    }
    
    function removeContract(bytes32 name) returns (bool) {
        var action_manager = contracts["actions"];
        var actionDb = contracts["actiondb"];
        if (action_manager != 0x0 || actionDb == 0x0) {
            bool validated = Validator(action_manager).validate(msg.sender);
            if (!validated) return false;
        }
        address contractAddr = contracts[name];
        if (contractAddr == 0x0) return false;
        ContractManagerEnabled(contractAddr).remove();
        contracts[name] = 0x0;
        return true;
    }
    
    function remove() {
        if (msg.sender == owner) suicide(owner);
    }
}

contract ActionManager is ContractManagerEnabled {
    
    struct ActionLogEntry {
        address caller;
        bytes32 action;
        uint blockNumber;
        bool success;
    }
    
    bool LOGGING = true;
    
    address activeAction;
    address caller;
    uint8 permToLock = 255;
    bool locked;
    
    uint public nextEntry = 0;
    mapping(uint => ActionLogEntry) public logEntries;
    
    function ActionManager() {
        permToLock = 255;
    }
    
    function returnCaller() returns (address) {
        return caller;
    }
    
    function returnActiveAction() returns (address) {
        return activeAction;
    }
    
    function execute(bytes32 actionName, bytes data) returns (bool) {
        caller = msg.sender;
        address actionDb = ContractProvider(cm).contracts("actiondb");
        if (actionDb == 0x0) {
            _log(actionName,false);
            return false;
        }
        address actn = ActionDb(actionDb).actions(actionName);
        if (actn == 0x0) {
            _log(actionName,false);
            return false;
        }
        address perms = ContractProvider(cm).contracts("perms");
        if (perms != 0x0) {
            Permissions p = Permissions(perms);
            uint8 perm = p.perms(msg.sender);
            if (locked && perm < permToLock) {
                _log(actionName,false);
                return false;
            }
            uint8 permReq = Action(actn).permission();
            if (perm < permReq) {
                _log(actionName,false);
                return false;
            }
        }
        activeAction = actn;
        actn.call(data);
        activeAction = 0x0;
        caller = 0x0;
        _log(actionName,true);
    }
    function lock() returns (bool) {
        if (msg.sender != activeAction) return false;
        if (locked) return false;
        locked = true;
    }
    
    function unlock() returns (bool) {
        if (msg.sender != activeAction) return false;
        if(!locked) return false;
        locked = false;
    }
    
    function validate(address addr) constant returns (bool) {
        return addr == activeAction;
    }
    
    function _log(bytes32 actionName, bool success) internal {
        if (msg.sender != address(this)) return;
        ActionLogEntry log_entry = logEntries[nextEntry++];
        log_entry.caller = msg.sender;
        log_entry.action = actionName;
        log_entry.success = success;
        log_entry.blockNumber = block.number;
    }
}