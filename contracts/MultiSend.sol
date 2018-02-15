// Copyright (C) 2018 Alon Bukai This program is free software: you 
// can redistribute it and/or modify it under the terms of the GNU General 
// Public License as published by the Free Software Foundation, version. 
// This program is distributed in the hope that it will be useful, 
// but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details. You should have received a copy of the GNU General Public
// License along with this program. If not, see http://www.gnu.org/licenses/

pragma solidity ^0.4.18;

import "giveth-common-contracts/contracts/Escapable.sol";
import "giveth-common-contracts/contracts/SafeMath.sol";

/// @notice `MultiSend` is a contract for sending multiple ETH/ERC20 Tokens to
///  multiple addresses. In addition this contract can call multiple contracts
///  with multiple amounts. There are also TightlyPacked functions which in
///  some situations allow for gas savings. TightlyPacked is cheaper if you
///  need to store input data and if amount is less than 12 bytes. Normal is
///  cheaper if you don't need to store input data or if amounts are greater
///  than 12 bytes. 12 bytes allows for sends of up to 2^96-1 units, 79 billion
///  ETH, so tightly packed functions will work for any ETH send but may not 
///  work for token sends when the token has a high number of decimals or a 
///  very large total supply. Supports deterministic deployment. As explained
///  here: https://github.com/ethereum/EIPs/issues/777#issuecomment-356103528
contract MultiSend is Escapable {
  
    /// @dev Hardcoded escapeHatchCaller
    address CALLER = 0x839395e20bbB182fa440d08F850E6c7A8f6F0780;
    /// @dev Hardcoded escapeHatchDestination
    address DESTINATION = 0x8ff920020c8ad673661c8117f2855c384758c572;

    event MultiTransfer(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount
    );

    event MultiCall(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount
    );

    event MultiERC20Transfer(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount,
        ERC20 _token
    );

    /// @notice Constructor using Escapable and Hardcoded values
    function MultiSend() Escapable(CALLER, DESTINATION) public {}

    /// @notice Send to multiple addresses using a byte32 array which
    ///  includes the address and the amount.
    ///  Addresses and amounts are stored in a packed bytes32 array
    ///  Address is stored in the 20 most significant bytes
    ///  The address is retrieved by bitshifting 96 bits to the right
    ///  Amount is stored in the 12 least significant bytes
    ///  The amount is retrieved by taking the 96 least significant bytes
    ///  and converting them into an unsigned integer
    ///  Payable
    /// @param _addressesAndAmounts Bitwise packed array of addresses
    ///  and amounts
    function multiTransferTightlyPacked(bytes32[] _addressesAndAmounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeTransfer(to, uint(uint96(_addressesAndAmounts[i])));
            toReturn = SafeMath.sub(toReturn, amount);
            MultiTransfer(msg.sender, msg.value, to, amount);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    /// @notice Send to multiple addresses using two arrays which
    ///  includes the address and the amount.
    ///  Payable
    /// @param _addresses Array of addresses to send to
    /// @param _amounts Array of amounts to send
    function multiTransfer(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeTransfer(_addresses[i], _amounts[i]);
            toReturn = SafeMath.sub(toReturn, _amounts[i]);
            MultiTransfer(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    /// @notice Call to multiple contracts using a byte32 array which
    ///  includes the contract address and the amount.
    ///  Addresses and amounts are stored in a packed bytes32 array.
    ///  Address is stored in the 20 most significant bytes.
    ///  The address is retrieved by bitshifting 96 bits to the right
    ///  Amount is stored in the 12 least significant bytes.
    ///  The amount is retrieved by taking the 96 least significant bytes
    ///  and converting them into an unsigned integer.
    ///  Payable
    /// @param _addressesAndAmounts Bitwise packed array of contract
    ///  addresses and amounts
    function multiCallTightlyPacked(bytes32[] _addressesAndAmounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeCall(to, amount);
            toReturn = SafeMath.sub(
                toReturn,
                uint(uint96(_addressesAndAmounts[i]))
            );
            MultiCall(msg.sender, msg.value, to, amount);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    /// @notice Call to multiple contracts using two arrays which
    ///  includes the contract address and the amount.
    /// @param _addresses Array of contract addresses to call
    /// @param _amounts Array of amounts to send
    function multiCall(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeCall(_addresses[i], _amounts[i]);
            toReturn = SafeMath.sub(toReturn, _amounts[i]);
            MultiCall(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    /// @notice Send ERC20 tokens to multiple contracts 
    ///  using a byte32 array which includes the address and the amount.
    ///  Addresses and amounts are stored in a packed bytes32 array.
    ///  Address is stored in the 20 most significant bytes.
    ///  The address is retrieved by bitshifting 96 bits to the right
    ///  Amount is stored in the 12 least significant bytes.
    ///  The amount is retrieved by taking the 96 least significant bytes
    ///  and converting them into an unsigned integer.
    /// @param _token The token to send
    /// @param _addressesAndAmounts Bitwise packed array of addresses
    ///  and token amounts
    function multiERC20TransferTightlyPacked
    (
        ERC20 _token,
        bytes32[] _addressesAndAmounts
    ) public {
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeERC20Transfer(_token, to, amount);
            MultiERC20Transfer(msg.sender, msg.value, to, amount, _token);
        }
    }

    /// @notice Send ERC20 tokens to multiple contracts
    ///  using two arrays which includes the address and the amount.
    /// @param _token The token to send
    /// @param _addresses Array of addresses to send to
    /// @param _amounts Array of token amounts to send
    function multiERC20Transfer(
        ERC20 _token,
        address[] _addresses,
        uint[] _amounts
    ) public {
        for (uint i = 0; i < _addresses.length; i++) {
            _safeERC20Transfer(_token, _addresses[i], _amounts[i]);
            MultiERC20Transfer(
                msg.sender,
                msg.value,
                _addresses[i],
                _amounts[i],
                _token
            );
        }
    }

    /// @notice `_safeTransfer` is used internally to transfer funds safely.
    function _safeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.transfer(_amount);
    }

    /// @notice `_safeCall` is used internally to call a contract safely.
    function _safeCall(address _to, uint _amount) internal {
        require(_to != 0);
        require(_to.call.value(_amount)());
    }

    /// @notice `_safeERC20Transfer` is used internally to
    ///  transfer a quantity of ERC20 tokens safely.
    function _safeERC20Transfer(ERC20 _token, address _to, uint _amount) internal {
        require(_to != 0);
        require(_token.transferFrom(msg.sender, _to, _amount));
    }

    /// @dev Default payable function to not allow sending to contract
    ///  Remember this does not necessarily prevent the contract
    ///  from accumulating funds.
    function () public payable {
        revert();
    }
}
