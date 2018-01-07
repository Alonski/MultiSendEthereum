pragma solidity ^0.4.18;

import "giveth-common-contracts/contracts/Escapable.sol";

contract MultiSend is Escapable {

  uint256 constant D160 = 0x0010000000000000000000000000000000000000000;
  
  function MultiSend(address _escapeHatchCaller, address _escapeHatchDestination)
    Escapable(_escapeHatchCaller, _escapeHatchDestination) public 
    {
    }
  
  // data is an array of uint256s. Each uint256 represents a transfer.
  // The 160 LSB is the destination of the address that wants to be sent
  // The 96 MSB is the amount of tokens that wants to be sent.
  function multiSendBitMask(uint256[] data) public payable {
    for (uint256 i = 0; i < data.length; i++) {
      address addr = address(data[i] & (D160 - 1));
      uint256 amount = data[i] / D160;
      
      require(amount > 0);
      
      require(addr != address(0));
      
      addr.transfer(amount);
    }
  }
  
  function multiSendTwo(address[2] addresses, uint[2] amounts) public payable {
    uint leftOver = msg.value - amounts[0] - amounts[1];
    require(leftOver >= 0);
    require(amounts[0] > 0);
    require(amounts[1] > 0);
    require(addresses[0] != address(0));
    require(addresses[1] != address(0));
    addresses[0].transfer(amounts[0]);
    addresses[1].transfer(amounts[1]);
    msg.sender.transfer(leftOver);
  }
  
  function multiSendThree(address[3] addresses, uint[3] amounts) public payable {
    uint leftOver = msg.value - amounts[0] - amounts[1] - amounts[2];
    require(leftOver >= 0);
    require(amounts[0] > 0);
    require(amounts[1] > 0);
    require(amounts[2] > 0);
    require(addresses[0] != address(0));
    require(addresses[1] != address(0));
    require(addresses[2] != address(0));
    addresses[0].transfer(amounts[0]);
    addresses[1].transfer(amounts[1]);
    addresses[2].transfer(amounts[2]);
    msg.sender.transfer(leftOver);
  }
  
  function multiSendFour(address[4] addresses, uint[4] amounts) public payable {
    require(amounts[0] + amounts[1] <= msg.value);
    require(amounts[0] > 0);
    require(amounts[1] > 0);
    require(amounts[2] > 0);
    require(amounts[3] > 0);
    require(addresses[0] != address(0));
    require(addresses[1] != address(0));
    require(addresses[2] != address(0));
    require(addresses[3] != address(0));
    addresses[0].transfer(amounts[0]);
    addresses[1].transfer(amounts[1]);
    addresses[2].transfer(amounts[2]);
    addresses[3].transfer(amounts[3]);
  }
  
  function () public payable {
    revert();
  }
}