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
        address expected = address(0x8ff920020c8ad673661c8117f2855c384758c572);

        address destination = multiSender.escapeHatchDestination();

        Assert.equal(expected, destination,
        "Escape Hatch Caller is Address is 0x8ff920020c8ad673661c8117f2855c384758c572");
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

    /* function testCanSendToThreeAddresses() public {
        uint expected = this.balance-150;

        address first = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
        address second = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;
        address third = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;
        
        uint amountFirst = 50;
        uint amountSecond = 50;
        uint amountThird = 50;

        multiSender.multiSendThree.value(150)([first,second,third],[amountFirst,amountSecond,amountThird]);

        uint afterSend = this.balance;

        Assert.equal(afterSend, expected, "Balance is correct after ThreeSend");
    }

    function testCanSendToFourAddresses() public {
        uint expected = this.balance-200;

        address first = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
        address second = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;
        address third = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;
        address fourth = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
        
        uint amountFirst = 50;
        uint amountSecond = 50;
        uint amountThird = 50;
        uint amountFourth = 50;

        multiSender.multiSendFour.value(200)([first,second,third,fourth],
        [amountFirst,amountSecond,amountThird,amountFourth]);

        uint afterSend = this.balance;

        Assert.equal(afterSend, expected, "Balance is correct after FourSend");
    } */

    function () public payable {

    }
}