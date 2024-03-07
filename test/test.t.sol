// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {TresureBox, SecretCastle} from "../src/challenge.sol";

contract SecretCastleTest is Test {
    TresureBox public sorcererStone;
    SecretCastle public castle;
    address public heroAddress;
    address builderAddress = vm.addr(2);

    function setUp() public {
        vm.startPrank(builderAddress);
        sorcererStone = new TresureBox();
        heroAddress = vm.addr(1);

        castle = new SecretCastle(sorcererStone);
        sorcererStone.transferFrom(builderAddress, address(castle), 6);
        vm.stopPrank();
    }

    function testUnlockSecretCastle() public {
        vm.startPrank(heroAddress);
        address shapeshiftingSword;
        // implement your logics here

        // With all four gates unlocked, the hero claims the sorcerer's stone
        castle.success(shapeshiftingSword);
        vm.stopPrank();

        assertEq(sorcererStone.ownerOf(6), heroAddress);
        console.log("Gas limit used:", castle.GAS_LIMIT());
        console.log("Number of Transactions:", vm.getNonce(heroAddress));
    }
}