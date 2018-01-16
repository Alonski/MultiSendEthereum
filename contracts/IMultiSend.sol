// Copyright (C) 2018 Alon Bukai This program is free software: you 
// can redistribute it and/or modify it under the terms of the GNU General 
// Public License as published by the Free Software Foundation, version. 
// This program is distributed in the hope that it will be useful, 
// but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details. You should have received a copy of the GNU General Public
// License along with this program. If not, see http://www.gnu.org/licenses/

pragma solidity ^0.4.19;

import "giveth-common-contracts/contracts/Escapable.sol";

/// @notice `MultiSend` is a contract for sending multiple ETH/ERC20 Tokens to
///  multiple addresses. In addition this contract can call multiple contracts
///  with multiple amounts. There are also TightlyPacked functions which in
///  some situations allow for gas savings. TightlyPacked is cheaper if you
///  need to store input data and if amount is less than 12 bytes. Normal is
///  cheaper if you don't need to store input data or if amounts are greater
///  than 12 bytes. Supports deterministic deployment. As explained
///  here: https://github.com/ethereum/EIPs/issues/777#issuecomment-356103528
interface IMultiSend{

    /// @notice Constructor using Escapable and Hardcoded values
    function MultiSend() Escapable(CALLER, DESTINATION) public;

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
    payable public returns(bool);

    /// @notice Send to multiple addresses using two arrays which
    ///  includes the address and the amount.
    ///  Payable
    /// @param _addresses Array of addresses to send to
    /// @param _amounts Array of amounts to send
    function multiTransfer(address[] _addresses, uint[] _amounts)
    payable public returns(bool);

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
    payable public returns(bool);

    /// @notice Call to multiple contracts using two arrays which
    ///  includes the contract address and the amount.
    /// @param _addresses Array of contract addresses to call
    /// @param _amounts Array of amounts to send
    function multiCall(address[] _addresses, uint[] _amounts)
    payable public returns(bool);

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
    );

    /// @notice Send ERC20 tokens to multiple contracts
    ///  using two arrays which includes the address and the amount.
    /// @param _token The token to send
    /// @param _addresses Array of addresses to send to
    /// @param _amounts Array of token amounts to send
    function multiERC20Transfer(
        ERC20 _token,
        address[] _addresses,
        uint[] _amounts
    );

    /// @notice `_safeTransfer` is used internally when transfer funds safely.
    function _safeTransfer(address _to, uint _amount) internal;

    /// @notice `_safeCall` is used internally when call a contract safely.
    function _safeCall(address _to, uint _amount) internal;

    /// @notice `_safeERC20Transfer` is used internally when
    ///  transfer a quantity of ERC20 tokens.
    function _safeERC20Transfer(ERC20 _token, address _to, uint _amount)
    internal;

    /// @dev Default payable function to not allow sending to contract;
    ///  remember this does not necesarily prevent the contract
    ///  from accumulating funds.
    function () public payable;
}