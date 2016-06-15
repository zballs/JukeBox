contract ContractProvider {
    function contracts(bytes32 name) returns (address) {}
}

contract Permissioner {
    function permission(address addr) constant returns (uint8) {}
}

contract Validator {
    function validate(address addr) constant returns (bool) {}
}

contract Adder {
    function addArtist(bytes32 name, bytes32 genre) returns (bool) {}
    function addAlbum(bytes32 title, bytes32 genre, address artist, uint8 price) returns (bool) {}
    function addSong(bytes32 title, bytes32 genre, address artist, uint8 price) returns (bool) {}
}

contract Purchaser {
    function purchase(address addr) returns (bool) {}
}

contract Player {
    function play(address addr) returns (bool) {}
}

contract Abstract {
    function add(bytes32 name_or_title, bytes32 genre) returns (bool) {}
    function album(bytes32 title, Album album) returns (bool) {}
    function song(bytes32 title, Song song) returns (bool) {}
    function play(address listener) returns (bool) {}
    function purchase(address buyer) returns (bool) {}
    function returnAlb() returns (address) {}
    function returnArt() returns (address) {}
    function returnJbx() returns (address) {}
    function returnPrice() returns (uint8) {}
    function setId(address Id) returns (bool) {}
    function setAlb(address album) returns (bool) {}
    function setArt(address artist) returns (bool) {}
    function setJbx() returns (bool) {}
    function setPrice(uint8 price) returns (bool) {}
    function validId(address Id) returns (bool) {}
}