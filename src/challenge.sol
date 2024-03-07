// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import '@solmate/src/tokens/ERC721.sol';

contract TresureBox is ERC721 {
    constructor() ERC721('sorcererStone', 'sorC') {
        _mint(msg.sender, 6); // Mint the sorcerer's stone (NFT) to the deployer
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return string(abi.encodePacked(id));
    }

    function contractURI() public view virtual returns (string memory) {
        return "https://example.com/contract-metadata";
    }
}

interface Sword {
    function isValidKey(bytes4 role) external returns (bool);
}

/**
 * @title Secret Castle
 * @dev In a world of magic and mystery, a secret castle holds an ancient and powerful artifact - the sorcerer's stone.
 *      To claim this invaluable treasure, one must navigate through a series of enchanted gates, each guarded by a
 *      powerful spell. Only the bravest and most cunning souls can wield the legendary shapeshifting sword, which
 *      holds the key to unlocking these gates.
 */
contract SecretCastle {
    uint256 public constant GAS_LIMIT = 40; // The shapeshifting sword has limited energy, consuming no more than 40 gas units per gate

    mapping(address => uint256) private challengeStates; // Keep track of the challenges completed by each sword

    bytes4 constant GATE_1 = 0x4e2312e0; // The first gate's spell
    bytes4 constant GATE_2 = 0x88a7ca5c; // The second gate's spell
    bytes4 constant GATE_3 = 0x13371337; // The third gate's spell
    bytes4 constant GATE_4 = 0xdecafc0f; // The fourth gate's spell

    uint256 constant GATE_1_FLAG = 1 << 0; // Flag indicating the completion of the first gate's challenge
    uint256 constant GATE_2_FLAG = 1 << 1; // Flag indicating the completion of the second gate's challenge
    uint256 constant GATE_3_FLAG = 1 << 2; // Flag indicating the completion of the third gate's challenge
    uint256 constant GATE_4_FLAG = 1 << 3; // Flag indicating the completion of the fourth gate's challenge

    bytes32[] private gateKeepers = [
        keccak256(abi.encodePacked(GATE_1)),
        keccak256(abi.encodePacked(GATE_2)),
        keccak256(abi.encodePacked(GATE_3)),
        keccak256(abi.encodePacked(GATE_4))
    ]; // The guardians of the gates, encoded as keccak256 hashes

    ERC721 private award; // The sorcerer's stone (NFT)

    constructor(ERC721 finalLevelPRice) {
        award = finalLevelPRice; // Initialize the sorcerer's stone contract
    }

    /**
     * @dev The shapeshifting sword must prove its worth by taking on the form of the gate's spell.
     *      However, with limited energy, it must be careful not to exhaust its powers.
     */
    function _isValidPassword(address sword, bytes4 gatePassword)
        public
        returns (bool)
    {
        return Sword(sword).isValidKey{gas: GAS_LIMIT}(gatePassword);
    }

    /**
     * @dev Attempt to open a gate by providing the correct spell (gatePassword) and the shapeshifting sword.
     *      The sword must take on the form of the gate's spell and pass additional checks to prove its worth.
     */
    function challenge(address sword, bytes4 gatePassword) external {
        uint256 expectedFlag; // The flag representing the current gate's challenge
        for (uint256 i = 0; i < gateKeepers.length; i++) {
            if (gateKeepers[i] == keccak256(abi.encodePacked(gatePassword))) {
                expectedFlag = (1 << i);
                break;
            }
        }

        require(expectedFlag != 0, "Invalid gate password"); // Ensure the provided gate password is valid
        require((challengeStates[sword] & expectedFlag) == 0, "Challenge already completed"); // Ensure the challenge hasn't been completed yet

        // Each gate has its own set of additional checks the sword must pass
        if (gatePassword == GATE_1) {
            require(_isValidPassword(sword, GATE_1), "Failed to take the form of Gate 1's spell");
            require(!_isValidPassword(sword, GATE_2), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_3), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_4), "Sword must not take the form of other gate spells");
        } else if (gatePassword == GATE_2) {
            require(_isValidPassword(sword, GATE_2), "Failed to take the form of Gate 2's spell");
            require(!_isValidPassword(sword, GATE_1), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_3), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_4), "Sword must not take the form of other gate spells");
        } else if (gatePassword == GATE_3) {
            require(_isValidPassword(sword, GATE_3), "Failed to take the form of Gate 3's spell");
            require(!_isValidPassword(sword, GATE_1), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_2), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_4), "Sword must not take the form of other gate spells");
        } else if (gatePassword == GATE_4) {
            require(_isValidPassword(sword, GATE_4), "Failed to take the form of Gate 4's spell");
            require(!_isValidPassword(sword, GATE_1), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_2), "Sword must not take the form of other gate spells");
            require(!_isValidPassword(sword, GATE_3), "Sword must not take the form of other gate spells");
        }

        challengeStates[sword] |= expectedFlag; // Mark the challenge as completed for the sword
    }

    /**
     * @dev If the shapeshifting sword has successfully completed all challenges and opened all gates,
     *      it can claim the sorcerer's stone as its prize.
     */
    function success(address sword) external {
        require(
            challengeStates[sword] ==
                (GATE_1_FLAG | GATE_2_FLAG | GATE_3_FLAG | GATE_4_FLAG),
            "All challenges not completed"
        );

        delete challengeStates[sword]; // Reset the challenge state for the sword

        require(award.ownerOf(6) == address(this), "The sorcerer's stone is not owned by this contract");
        award.transferFrom(address(this), msg.sender, 6); // Transfer the sorcerer's stone (NFT) to the winner
    }
}
