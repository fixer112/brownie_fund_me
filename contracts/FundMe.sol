// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    // if you're following along with the freecodecamp video
    // Please see https://github.com/PatrickAlphaC/fund_me
    // to get the starting solidity contract code, it'll be slightly different than this!
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;
        uint256 value = msg.value;
        require(
            getConversionRate(value) >= minimumUSD,
            string.concat(
                "You need at least ",
                Strings.toString(minimumUSD),
                " to fund this project. You paid ",
                Strings.toString(value)
            )
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        withdraw();
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee(uint256 usd) public view returns (uint256) {
        // minimumUSD

        //return ((msg.sender.balance / 10**18) * (getPrice() / 10**18));
        uint256 minimumUSD = usd * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable {
        address payable receiver = payable(
            0x0f538f2165d811a8db500698818dD8684dd78e79 // receiver address
        );
        payable(receiver).transfer(address(this).balance);
        //payable(msg.sender).transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
