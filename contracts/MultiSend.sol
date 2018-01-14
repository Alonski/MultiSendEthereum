pragma solidity ^0.4.18;

import "giveth-common-contracts/contracts/Escapable.sol";

// TightlyPacked is cheaper if you need to store input data and if amount is less than 12 bytes.
// Normal is cheaper if you don't need to store input data or if amounts are greater than 12 bytes.
// Supports deterministic deployment. As explained here: https://github.com/ethereum/EIPs/issues/777#issuecomment-356103528
contract MultiSend is Escapable {
  
  address CALLER = 0x839395e20bbB182fa440d08F850E6c7A8f6F0780;
  address DESTINATION = 0x8ff920020c8ad673661c8117f2855c384758c572;

  function MultiSend() Escapable(CALLER, DESTINATION) public {}
  
  function multiTransferTightlyPacked(bytes32[] _addressAndAmount) payable public returns(bool) {
    for (uint i = 0; i < _addressAndAmount.length; i++) {
        _safeTransfer(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
    }
    return true;
  }

  function multiTransfer(address[] _address, uint[] _amount) payable public returns(bool) {
    for (uint i = 0; i < _address.length; i++) {
        _safeTransfer(_address[i], _amount[i]);
    }
    return true;
  }

  function multiCallTightlyPacked(bytes32[] _addressAndAmount) payable public returns(bool) {
      for (uint i = 0; i < _addressAndAmount.length; i++) {
          _safeCall(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
      }
      return true;
  }

  function multiCall(address[] _address, uint[] _amount) payable public returns(bool) {
      for (uint i = 0; i < _address.length; i++) {
          _safeCall(_address[i], _amount[i]);
      }
      return true;
  }

  function multiERC20TransferTightlyPacked(ERC20 _token, bytes32[] _addressAndAmount) public returns(bool) {
      for (uint i = 0; i < _addressAndAmount.length; i++) {
          _safeERC20Transfer(_token, address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
      }
      return true;
  }

  function multiERC20Transfer(ERC20 _token, address[] _address, uint[] _amount) public returns(bool) {
      for (uint i = 0; i < _address.length; i++) {
          _safeERC20Transfer(_token, _address[i], _amount[i]);
      }
      return true;
  }

  function _safeTransfer(address _to, uint _amount) internal {
      require(_to != 0);
      _to.transfer(_amount);
  }

  function _safeCall(address _to, uint _amount) internal {
      require(_to != 0);
      require(_to.call.value(_amount)());
  }

  function _safeERC20Transfer(ERC20 _token, address _to, uint _amount) internal {
      require(_to != 0);
      require(_token.transferFrom(msg.sender, _to, _amount));
  }
  
  function () public payable {
    revert();
  }
}