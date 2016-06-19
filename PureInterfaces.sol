// Pure interfaces

contract ContractProvider {
    function contracts(bytes32 name) returns (address) {}
}

contract Permissioner { 
    function perm() constant returns (uint8) {}
    function perms(address addr) constant returns (uint8) {}
    function setPerm(uint8 perm) returns (bool) {}
    function setPerm(address addr, uint8 perm) returns (bool) {}
}

contract Registry {
    function register(bytes32 name) returns (bool) {}
    function unregister(bytes32 name) returns (bool) {}
    function check(address addr) returns (bool) {}
}

contract Validator {
    function validate(address addr) constant returns (bool) {}
}

contract UserInterface {
    function addArtist(bytes32 name, bytes32 genre) returns (bool) {}
    function removeArtist(address artistAddr) returns (bool) {}
    
    function addAlbum(bytes32 name, bytes32 genre, uint8 price) returns (bool) {}
    function removeAlbum(address albumAddr) returns (bool) {}
    
    function addSong(bytes32 name, bytes32 genre, uint8 price, address albumAddr) returns (bool) {}
    function removeSong(address songAddr, bool justFromAlbum) returns (bool) {}
    
    function access(address addr) returns (bool) {}
    function get(address addr) returns (bool) {}
}

contract JbxInterface {
    
    function name() returns (bytes32) {}
    function setName(bytes32 name) returns (bool) {}
    
    function genre() returns (bytes32) {}
    function setGenre(bytes32 genre) returns (bool) {}
    
    function price() returns (uint8) {}
    function setPrice(uint8 price) returns (bool) {}
    
    function artist() returns (address) {}
    function setArtist(address artistAddr) returns (bool) {}
    
    function album() returns (address) {}
    function album(bytes32 name, Album album) returns (bool) {}
    function setAlbum(address albumAddr) returns (bool) {}
    function dropAlbum(bytes32 name) returns (bool) {}
    
    function song(bytes32 name, Song song) returns (bool) {}
    function dropSong(bytes32 name) returns (bool) {}
    
    function access(address accessor) returns (bool) {}
    function get(address addr) returns (bool) {}
    function remove() {}
}