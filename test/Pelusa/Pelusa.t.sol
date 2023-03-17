// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {BaseTest} from "../utils/BaseTest.sol";

contract PelusaTest is BaseTest {
    address attacker;

    constructor() {
        string[] memory labels = new string[](1);
        labels[0] = "Attacker";

        preSetup(1, labels);
    }

    function setUp() public override {
        super.setUp();
        attacker = users[0];
    }

    function test_Pelusa() public {
        runTest();
    }

    function exploit() internal override {}

    function success() internal override {}
}

pragma solidity ^0.8.17;

interface IGame {
    function getBallPossesion() external view returns (address);
}

// "el baile de la gambeta"
// https://www.youtube.com/watch?v=qzxn85zX2aE

/// @title Pelusa
/// @author https://twitter.com/eugenioclrc
/// @notice Its 1986, you are in the football world cup (Mexico86), help Diego score a goal.
/// @custom:url https://www.ctfprotocol.com/tracks/eko2022/pelusa
contract Pelusa {
    address private immutable owner;

    address internal player;

    uint256 public goals = 1;

    constructor() {
        owner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(msg.sender, blockhash(block.number))
                    )
                )
            )
        );
    }

    function passTheBall() external {
        require(msg.sender.code.length == 0, "Only EOA players");
        /// @dev "la pelota siempre al 10"
        require(uint256(uint160(msg.sender)) % 100 == 10, "not allowed");

        player = msg.sender;
    }

    function isGoal() public view returns (bool) {
        // expect ball in owners posession
        return IGame(player).getBallPossesion() == owner;
    }

    function shoot() external {
        require(isGoal(), "missed");
        /// @dev use "the hand of god" trick
        (bool success, bytes memory data) = player.delegatecall(
            abi.encodeWithSignature("handOfGod()")
        );
        require(success, "missed");
        require(uint256(bytes32(data)) == 22_06_1986);
    }
}
