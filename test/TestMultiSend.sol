pragma solidity ^0.4.18;

import 'truffle/Assert.sol';
import 'truffle/DeployedAddresses.sol';
import '../contracts/MultiSend.sol';

contract TestMultiSend {
    MultiSend multiSender = MultiSend(DeployedAddresses.MultiSend());
    uint public initialBalance = 10 ether;

    function testCanSendToTwoAddresses() public {
        uint expected = this.balance-100;

        address first = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
        address second = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE;
        
        uint amountFirst = 50;
        uint amountSecond = 50;

        multiSender.multiSendTwo.value(100)([first,second],[amountFirst,amountSecond]);

        uint afterSend = this.balance;

        Assert.equal(afterSend, expected, "Balance is correct after TwoSend");
    }

    function testCanSendToThreeAddresses() public {
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
    }

    function () public payable {

    }
}