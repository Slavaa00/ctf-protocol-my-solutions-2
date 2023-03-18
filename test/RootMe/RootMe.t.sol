// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title RootMe
/// @author https://twitter.com/tinchoabbate
/// @notice Anon, can you trick the machine to get root access?
/// @custom:url https://www.ctfprotocol.com/tracks/eko2022/rootme
contract RootMe {
    bool public victory;

    mapping(string => bool) public usernames;
    mapping(bytes32 => address) public accountByIdentifier;

    constructor() {
        register("ROOT", "ROOT");
    }

    modifier onlyRoot() {
        require(
            accountByIdentifier[_getIdentifier("ROOT", "ROOT")] == msg.sender,
            "Not authorized"
        );
        _;
    }

    function register(string memory username, string memory salt) public {
        require(usernames[username] == false, "Username already exists");

        usernames[username] = true;

        bytes32 identifier = _getIdentifier(username, salt);
        accountByIdentifier[identifier] = msg.sender;
    }

    function _getIdentifier(
        string memory user,
        string memory salt
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, salt));
    }

    /**
     * @notice Allows root account to perform any change in the contract's storage
     * @param storageSlot storage position where data will be written
     * @param data data to be written
     */
    function write(bytes32 storageSlot, bytes32 data) external onlyRoot {
        assembly {
            // stores `data` in storage at position `storageSlot`
            sstore(storageSlot, data)
        }
    }
}

contract Check {
    // "ROO" "TROOT"
    // 0x86c4884d46e73de474ea1dc7c8955050781cb540860675454815ce38d996a10a
    function _getIdentifier(
        string memory user,
        string memory salt
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, salt));
    }

    // 0xd3cb35592e0723df2489793151259147bfa9b7a88018fdcf9e8705a8df74b0e7
    function getStorageLocationForKey(
        bytes32 _key,
        bytes32 _slot
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_key, _slot));
    }
}
// 0xe580dd1a7548d20d6720bbafe6acc4ab774dc38aaba0d460c7c02ae4e42abd05
// 0x0000000000000000000000000000000000000000000000000000000000000002
// 0x000000000000000000000000AfF1f53D623289851D4a64d4DA2f64D226665F0F
