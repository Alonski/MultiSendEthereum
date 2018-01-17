pragma solidity ^0.4.18;

// Copyright (C) 2018 Alon Bukai This program is free software: you 
// can redistribute it and/or modify it under the terms of the GNU General 
// Public License as published by the Free Software Foundation, version. 
// This program is distributed in the hope that it will be useful, 
// but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details. You should have received a copy of the GNU General Public
// License along with this program. If not, see http://www.gnu.org/licenses/

import "giveth-common-contracts/contracts/Escapable.sol";

/// @notice `MultiSend` is a contract for making multiple ETH/ERC20 Token sends
///  to multiple addresses and calling multiple contracts with multiple amounts; 
///  there are TightlyPacked functions which often allow for gas savings if
///  you need to store input data and the `amount` being sent is less than 12 
///  bytes (0xffffffffffff); supports deterministic deployment, explained here:
///  https://github.com/ethereum/EIPs/issues/777#issuecomment-356103528
contract MultiSend is Escapable {
  
    /// @dev Hardcoded escapeHatchCaller to Griff Green's DAO Curator Address
    address CALLER = 0x839395e20bbB182fa440d08F850E6c7A8f6F0780;

    /// @dev Hardcoded escapeHatchDestination to the WHG's Multisig 
    address DESTINATION = 0x8ff920020c8ad673661c8117f2855c384758c572;

//////////
// Events
//////////

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

///////////////
// Constructor
///////////////

    /// @notice Constructor using Escapable with Hardcoded values
    function MultiSend() Escapable(CALLER, DESTINATION) public {}

///////////////////
// Ether Functions
///////////////////


    /// @notice Most efficient function for Multisigs and other Contracts
    ///  to use; Allows you to send ether to multiple addresses by attaching a
    ///  byte32 array to the total ETH to be sent; the data includes the 
    ///  receiving address & the amount to be sent stored in a packed bytes32
    ///  array where the address is in the 20 leftmost bytes, retrieved by
    ///  bitshifting it 96 bits to the right, and the amount is stored in the 12
    ///  rightmost bytes, retrieved by taking the 96 rightmost bytes and
    ///  converting them into an unsigned integer
    /// @param _addressesAndAmounts Bitwise packed array of addresses and
    ///  amounts (denominated in wei) detailing the desired transfers
    function multiTransferTightlyPacked(bytes32[] _addressesAndAmounts
    )payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeTransfer(to, amount);
            MultiTransfer(msg.sender, msg.value, to, amount);
        }
        require(startBalance - msg.value == this.balance); // Accounting check
        return true;
    }

    /// @notice Most efficient function when sending from a normal account; 
    ///  Allows you to send ETH to multiple addresses by attaching two arrays of
    ///  data, one array for the addresses and one array for the amounts
    /// @param _addresses Array of addresses to receive ETH
    /// @param _amounts Array of amounts (in wei) to send to each address
    function multiTransfer(address[] _addresses, uint[] _amounts
    )payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeTransfer(_addresses[i], _amounts[i]);
            MultiTransfer(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        require(startBalance - msg.value == this.balance); // Accounting check
        return true;
    }

    /// @notice Most efficient function for Multisigs and other contracts
    ///  to use; Allows you to make calls to multiple contracts by attaching a
    ///  byte32 array to the total ETH to be sent; the data includes the
    ///  receiving address & the amount to be sent stored in a packed bytes32
    ///  array where the address is in the 20 leftmost bytes, retrieved by
    ///  bitshifting it 96 bits to the right, and the amount is stored in the 12
    ///  rightmost bytes, retrieved by taking the 96 rightmost bytes and
    ///  converting them into an unsigned integer; NOTE: Only calls without data
    ///  can be made from this contract
    /// @param _addressesAndAmounts Bitwise packed array of addresses and
    ///  amounts (denominated in wei) detailing the desired calls
    function multiCallTightlyPacked(bytes32[] _addressesAndAmounts
    )payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeCall(to, amount);
            MultiCall(msg.sender, msg.value, to, amount);
        }
        require(startBalance - msg.value == this.balance);
        return true;
    }

    /// @notice Most efficient function when using a normal account; Allows you
    ///  to call multiple contracts in one transaction by attaching two arrays
    ///  of data, one array for the addresses and one array for the amounts
    /// @param _addresses Array of contract addresses to be called
    /// @param _amounts Array of amounts (in wei) to send to each address
    function multiCall(address[] _addresses, uint[] _amounts
    )payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeCall(_addresses[i], _amounts[i]);
            MultiCall(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        require(startBalance - msg.value == this.balance);
        return true;
    }

///////////////////
// Token Functions
///////////////////

    /// @notice Most efficient function for Multisigs and other Contracts
    ///  to use; Allows you to send ERC20 tokens to multiple addresses by
    ///  attaching a byte32 array to the transaction; the data includes the
    ///  receiving address & the amount of tokens to be sent stored in a packed
    ///  bytes32 array where the address in the 20 leftmost bytes is retrieved
    ///  by bitshifting it 96 bits to the right, and the amount stored in the 12
    ///  rightmost bytes is retrieved by taking the 96 rightmost bytes and
    ///  converting them into an unsigned integer
    /// @param _token The token being sent
    /// @param _addressesAndAmounts Bitwise packed array of receiving addresses
    ///  amounts (denominated in the smallest unit of the token) detailing the
    ///  desired ERC20 transfers
    function multiERC20TransferTightlyPacked(
        ERC20 _token,
        bytes32[] _addressesAndAmounts
    ) public
    {
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeERC20Transfer(_token, to, amount);
            MultiERC20Transfer(msg.sender, msg.value, to, amount, _token);
        }
    }

    /// @notice Most efficient function when using a normal account; Allows you
    ///  to send ERC20 tokens to multiple addresses by attaching two arrays
    ///  of data, one array for the addresses and one array for the amounts
    /// @param _addresses Array of contract addresses to be called
    /// @param _amounts Array of amounts (in wei) to send to each address
    function multiERC20Transfer(
        ERC20 _token,
        address[] _addresses,
        uint[] _amounts
    ) public
    {
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

//////////////////////
// Internal Functions
//////////////////////

    /// @notice Transfers `_amount` of ETH (denominated in wei) safely to `_to` 
    function _safeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.transfer(_amount);
    }

    /// @notice Makes a safe call for `_amount` of ETH (in wei) to `_to`
    function _safeCall(address _to, uint _amount) internal {
        require(_to != 0);
        require(_to.call.value(_amount)());
    }


    /// @notice Transfers `_amount` of ERC20 tokens (denominated in the smallest
    ///  unit) safely to `_to`
    function _safeERC20Transfer(ERC20 _token, address _to, uint _amount
    )internal
    {
        require(_to != 0);
        require(_token.transferFrom(msg.sender, _to, _amount));
    }

    /// @dev The fallback function is written nicely to stop ether from being
    ///  sent to the contract but to give back as much gas as possible;
    ///  remember this does not necessarily prevent the contract from
    ///  accumulating ETH and tokens via other means
    function () public payable {
        revert();
    }
}
