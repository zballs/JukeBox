import "BaseContracts.sol";
import "Databases.sol";

// Contract Manager

contract ContractManager {
    
    address owner;
    mapping(bytes32 => address) public contracts;
    
    function ContractManager() {
        owner = msg.sender;
    }
    
    function add(bytes32 name, address addr) returns (bool) {
        var action_manager = contracts["actions"];
        if (action_manager != 0x0) {
            bool validated = Validator(action_manager).validate(msg.sender);
            if (!validated) return false;
        }
        ContractManagerEnabled cme = ContractManagerEnabled(addr);
        if (!cme.setContractManager(address(this))) return false;
        contracts[name] = addr;
        return true;
    }
    
    function remove(bytes32 name) returns (bool) {
        var action_manager = contracts["actions"];
        if (action_manager != 0x0) {
            bool validated = Validator(action_manager).validate(msg.sender);
            if (!validated) return false;
        }
        address contractAddr = contracts[name];
        if (contractAddr == 0x0) return false;
        ContractManagerEnabled(contractAddr).destroy();
        contracts[name] = 0x0;
        return true;
    }
    
    function destroy() {
        if (msg.sender == owner) suicide(owner);
    }
}

// Action Manager 

contract ActionManager is ContractManagerEnabled {
    
    struct ActionLogEntry {
        address caller;
        bytes32 action;
        uint blockNumber;
        bool success;
    }
    
    bool LOGGING = true;
    
    address activeAction;
    address public caller;
    uint8 permToLock = 255;
    bool locked;
    
    uint public nextEntry = 0;
    mapping(uint => ActionLogEntry) public logEntries;
    
    function ActionManager() {
        permToLock = 255;
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
        address permissions = ContractProvider(cm).contracts("permissions");
        if (permissions != 0x0) {
            uint8 userperm = Permissioner(permissions).perms(caller);
            if (locked && userperm < permToLock) {
                _log(actionName,false);
                return false;
            }
            uint8 permReq = Permissioner(actn).perm();
            if (userperm < permReq) {
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