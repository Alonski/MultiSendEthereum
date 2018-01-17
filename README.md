# MultiSend Smart Contract - Ethereum Solidity Truffle

This allows calling one function with parameters to send multiple amounts to multiple addresses

## Installation

1. Install Truffle globally.
    ```javascript
    npm install -g truffle
    ```

2. Install the necessary dependencies.
    ```javascript
    npm install
    ```

3. Run the development console.
    ```javascript
    truffle develop
    ```

4. Compile and migrate the smart contracts. Note inside the development console we don't preface commands with `truffle`.
    ```javascript
    compile
    migrate
    ```

5. Truffle can run tests written in Solidity or JavaScript against your smart contracts. Note the command varies slightly if you're in or outside of the development console.
    ```javascript
    // If inside the development console.
    test

    // If outside the development console..
    truffle test
    ```

## FAQ

* __How do I use this with the EthereumJS TestRPC?__

    It's as easy as modifying the config file! [Check out our documentation on adding network configurations](http://truffleframework.com/docs/advanced/configuration#networks). Depending on the port you're using, you'll also need to update line 34 of `src/util/web3/getWeb3.js`.

* __Why is there both a truffle.js file and a truffle-config.js file?__

    `truffle-config.js` is a copy of `truffle.js` for compatibility with Windows development environments. Feel free to remove it if it's irrelevant to your platform.


* __Where can I find more documentation?__

    Check out [Truffle](http://truffleframework.com/)


## Contributors
* [@Alonski](https://github.com/alonski) (Alon Bukai)
* [@Quazia](https://github.com/quazia) (Arthur Lunn)
* [@Lastperson](https://github.com/lastperson) (Oleksii Matiiasevych)
* [@GriffGreen](https://github.com/griffgreen) (Griff Green)
