// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title SmartHorrocrux
/// @author https://twitter.com/AugustitoQ
/// @notice Some security researchers have recently found an eighth Horrocrux, it seems that Voldemort has link to a smart contract, can you destroy it?
/// @custom:url https://www.ctfprotocol.com/tracks/eko2022/smart-horrocrux
contract SmartHorrocrux {
    bool private invincible;
    bytes32 private constant _spell =
        0x45746865724b6164616272610000000000000000000000000000000000000000;
    //                                0x41c0e1b500000000000000000000000000000000000000000000000000000000
    // var only for test purposes
    bool public alive = true;

    constructor() payable {
        require(msg.value == 2, "Pay Horrorcrux creation price");
        setInvincible();
    }

    function destroyIt(string memory spell, uint256 magic) public {
        bytes32 spellInBytes;
        assembly {
            spellInBytes := mload(add(spell, 32))
        }
        require(spellInBytes == _spell, "That spell wouldn't kill a fly");
        require(!invincible, "The Horrocrux is still invincible");

        bytes memory kedavra = abi.encodePacked(
            bytes4(bytes32(uint256(spellInBytes) - magic))
        );
        address(this).call(kedavra);
    }

    // 41c0e1b5
    // spell 0x45746865724b616461627261 == EtherKadabra

    // 31415261328370963944593163005606262356653643042768913171479931875817519316992 - 1674133761342824277929123818302714816965480662716616051558525647956333297664
    // == 29741127567028139666664039187303547539688162380052297119921406227861186019328 == 0x41C0E1B500000000000000000000000000000000000000000000000000000000
    // keccak256(kill()) == 0x41c0e1b5eba5f1ef69db2e30c1ec7d6e0a5f3d39332543a8a99d1165e460a49e

    //
    function kill() external {
        require(msg.sender == address(this), "No one can kill me");
        alive = false;
        selfdestruct(payable(tx.origin));
    }

    function setInvincible() public {
        invincible = (address(this).balance == 1) ? false : true;
    }

    fallback() external {
        uint256 b = address(this).balance;
        invincible = true;
        if (b > 0) {
            tx.origin.call{value: b}("");
        }
    }
}

contract Attack {
    constructor() payable {}

    function attack(address a) external {
        selfdestruct(payable(a));
    }
}
/*
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒░▒▒░░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒░░░░░░░░░░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒░░░░░░░░░░░░█▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░░░░░░░░░░░░░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒░▒██▓▓▒░▓████░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒█▓█▒░▓░▓▓▓▓░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░░░░▒░▓█▒░░▒▒░░▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█▓███░░░░░░░▓████▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█░▒█▓░░░░░░░▒█▒░▒█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▓▓▒▒███▓▓▓███░▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒░▓██▓███▓▓▓▒░░▓██▓█▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█▒▒▓▓███▓▓▒░░▒▒▓██▒▓▒░▓█▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓▓▒█░▓██▓█▓▒░░▓████▓▒▓░▒██▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓▓▒▒▒▓▓░░░▓▓░▓▒░▓░░▓██░░█▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█░░░▒░█░░░░▒▒▒▒░▓▒░░░▒█░▓░▓▓▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░███░▒▒▓░░░░░▓█░░▓▓░░░░▓▒▒░▒░▒▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▓▒░▓▓█░░░░░░█▓▓░▓░░░▒░▒▒▓░░▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▓█░░▓█▓░░░░░░█░░▓▓▒▒░▒█▓░░▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▓░░░░░█▓▓▒▒░▒█▓▓▒▒▓▓▒░░░▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█▓▓▒▒░░▓███████▒▒▒▒▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒███▓▓█▒░▒█████▓▒▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█▒▒░░▒█████▓▓██▒▒▓▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓▒░░░▓▓███░▒█░░██▓▒▒▒▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒█░░░░▓░░░██▒▓▒█░░███▓▒▒█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░░░░▒▒░░░▒▓█▒▓█░░█▒▒█▒▓█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▒░░░▒▓░░░░█▓▓▓▒▒█▒░░▓██▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░░░░▒▓▒▒▒█▓▒▒▓█▒░░░▓█▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓░░░░░▒██▓░▓██░░▒▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▓▒▒██▓▓░███▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▒▓▒▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▓▒░░▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▓░▓█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▒░░▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▒▓▒░▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒█▓▒▒▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▓▒▓█▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓▓░▓▓░░░░░░▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░▓▓░▒░░░▒▒█▓█▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▓▒▒▓░░▒▒▒████▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▓░▒▓░░▒░▒▓▓██▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█▒░▒▓░░▒░░░░▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒█▓░▒▓░░▓▒▒░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▒▒▒▒▓▒░░░▒█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒░░░░░░▒▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
*/
