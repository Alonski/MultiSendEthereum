// Copyright (C) 2018 Alon Bukai This program is free software: you 
// can redistribute it and/or modify it under the terms of the GNU General 
// Public License as published by the Free Software Foundation, version. 
// This program is distributed in the hope that it will be useful, 
// but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details. You should have received a copy of the GNU General Public
// License along with this program. If not, see http://www.gnu.org/licenses/

pragma solidity ^0.4.18;

import 'truffle/Assert.sol';
import 'truffle/DeployedAddresses.sol';
import '../contracts/MultiSend.sol';

contract TestMultiSend {
    MultiSend multiSender = MultiSend(DeployedAddresses.MultiSend());
    uint public initialBalance = 10 ether;

    function testEscapeHatchCallerIsGriff() public {
        address expected = address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780);

        address caller = multiSender.escapeHatchCaller();

        Assert.equal(expected, caller,
        "Escape Hatch Caller is Address is 0x839395e20bbB182fa440d08F850E6c7A8f6F0780");
    }

    function testEscapeHatchDestinationIsWHG() public {
        address expected = address(0x8Ff920020c8AD673661c8117f2855C384758C572);

        address destination = multiSender.escapeHatchDestination();

        Assert.equal(expected, destination,
        "Escape Hatch Caller is Address is 0x8Ff920020c8AD673661c8117f2855C384758C572");
    }

    function testCanSendToTwoAddresses() public {
        uint expected = this.balance-100;

        address firstAddress = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
        address secondAddress = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;

        address[] memory addresses = new address[](2);
        addresses[0] = firstAddress;
        addresses[1] = secondAddress;
        
        uint amountFirst = 50;
        uint amountSecond = 50;

        uint[] memory amounts = new uint[](2);
        amounts[0] = amountFirst;
        amounts[1] = amountSecond;

        multiSender.multiTransfer.value(100)(addresses,amounts);

        uint afterSend = this.balance;

        Assert.equal(afterSend, expected, "Balance is correct after TwoSend");
    }

    function testCanSendToTwoAddressesPacked() public {
        uint expected = this.balance-100;

        address firstAddress = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
        address secondAddress = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;

        uint amountFirst = 50;
        uint amountSecond = 50;

        bytes32 firstPacked = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc000000000000000000000032;
        bytes32 secondPacked = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE000000000000000000000032;

        bytes32[] memory addrAmountPacked = new bytes32[](2);
        addrAmountPacked[0] = firstPacked;
        addrAmountPacked[1] = secondPacked;

        multiSender.multiTransferTightlyPacked.value(100)(addrAmountPacked);

        uint afterSend = this.balance;
        Assert.equal(afterSend, expected, "Balance is correct after TwoSend");
    }

    function () public payable {

    }
}