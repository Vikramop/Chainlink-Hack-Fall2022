// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// goerli: "0xe36350eCC46968413a697A90c839F0C9022b9fDf"
// polygon : "0x96edf14974415F9191Ca9669c60f61E42a7C2DE0"

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract dicegame is VRFV2WrapperConsumerBase {
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

    address constant linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant vrfWrapperAddress =
        0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;

    uint256 constant entryFees = 0.05 ether;
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
