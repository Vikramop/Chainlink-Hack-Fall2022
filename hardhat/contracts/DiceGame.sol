// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract DiceRoll is VRFV2WrapperConsumerBase {
    event DiceRollRequest(uint256 requestId);
    event DiceRollResult(uint256 requestId, bool didwin);

    struct DiceRollStatus {
        uint fees;
        uint256 randomWord;
        address player;
        bool didwin;
        bool fulfilled;
        DiceRollSelection choice;
    }

    enum DiceRollSelection {
        LOW,
        HIGH
    }

    mapping(uint256 => DiceRollStatus) public statuses;

    address linkAddress = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
    address vrfWrapperAddress = "0x708701a1DfF4f478de54383E49a627eD4852C816";

    uint256 constant entryFees = 0.01 ether;
    uint32 constant callbackGasLimit = 1_000_000;
    uint32 constant numWords = 1;
    uint16 constant requestConfirmations = 3;

    constructor()
        payable
        VRFV2WrapperConsumerBase(linkAddress, vrfWrapperAddress)
    {}

    function Roll(DiceRollSelection choice) external payable returns (uint256) {
        require(msg.value == entryFees, "entry fees not sent");

        uint requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );

        statuses[requestId] = DiceRollStatus({
            fees: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWord: 0,
            player: msg.sender,
            didwin: false,
            fulfilled: false,
            choice: choice
        });

        emit DiceRollRequest(requestId);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(statuses[requestId].fees > 0, "Request not found");

        statuses[requestId].fulfilled = true;
        statuses[requestId].randomWord = randomWords[0];

        DiceRollSelection result = DiceRollSelection.HIGH;
        if (randomWords[0] % 2 == 0) {
            result = DiceRollSelection.LOW;
        }

        if (statuses[requestId].choice == result) {
            statuses[requestId].didwin == true;
            payable(statuses[requestId].player).transfer(entryFees * 2);
        }

        emit DiceRollResult(requestId, statuses[requestId].didwin);
    }

    function getStatus(uint256 requestId)
        public
        view
        returns (DiceRollStatus memory)
    {
        return statuses[requestId];
    }
}
