import "BaseContracts.sol";

contract ActionDb is ActionManagerEnabled {
    mapping (bytes32 => address) public actions;
    function setContractManager(address addr) returns (bool) {
        super.setContractManager(addr);
        var add_action = new AddAction();
        if (!ContractManagerEnabled(add_action).setContractManager(addr)) return false;
        actions["addaction"] = address(add_action);
    }
    function addAction(bytes32 name, address addr) returns (bool) {
        if (!isActionManager()) return false;
        bool contract_manager_set = ContractManagerEnabled(addr).setContractManager(cm);
        if (!contract_manager_set) return false;
        actions[name] = addr;
        return true;
    }
    function removeAction(bytes32 name) returns (bool) {
        if (!isActionManager()) return false;
        if (actions[name] == 0x0) return false;
        actions[name] = 0x0;
        return true;
    }
}