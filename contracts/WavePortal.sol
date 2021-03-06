// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /* 乱数生成のための基盤となるシード（種）を作成 */
    uint256 private seed;
    string private rarity;

    event NewWave(address indexed from, uint256 timestamp, string message, string rarity);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        string rarity;
    }

    Wave[] waves;

    /*
     * "address => uint mapping"は、アドレスと数値を関連付ける
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * 初期シードを設定
         */
        seed = (block.difficulty + block.timestamp + seed) % 10 * 100000;
        seed += ((block.difficulty + block.timestamp + seed)/10) % 10 * 10000;
        seed += ((block.difficulty + block.timestamp + seed)/100) % 10 * 1000;
        seed += ((block.difficulty + block.timestamp + seed)/1000) % 10 * 100;
        seed += ((block.difficulty + block.timestamp + seed)/10000) % 10 * 10;
    }

    function wave(string memory _message) public {
        /*
         * 現在ユーザーがwaveを送信している時刻と、前回waveを送信した時刻が15分以上離れていることを確認。
         */
        require(
            lastWavedAt[msg.sender] + 0 seconds < block.timestamp,
            "Wait"
        );

        /*
         * ユーザーの現在のタイムスタンプを更新する
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        /*
         * ユーザーのために乱数を生成
         */
        seed = (block.difficulty + block.timestamp + seed) % 10 * 100000;
        seed += ((block.difficulty + block.timestamp + seed)/10) % 10 * 10000;
        seed += ((block.difficulty + block.timestamp + seed)/100) % 10 * 1000;
        seed += ((block.difficulty + block.timestamp + seed)/1000) % 10 * 100;
        seed += ((block.difficulty + block.timestamp + seed)/10000) % 10 * 10;

        console.log("Random # generated: %d", seed);

        /*
         * ユーザーがETHを獲得する確率を50％に設定
         */
        if (seed < 66667) {
            console.log("%s got a rare reward!", msg.sender);
            rarity = "Rare prize! 0.0045 ETH";

            /*
             * レア: 1/15
             */
            uint256 prizeAmount = 0.0045 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else if (seed < 200000) {
            console.log("%s got an uncommon reward!", msg.sender);
            rarity = "Uncommon prize! 0.0001 ETH";

            /*
             * アンコモン: 3/15
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else {
            console.log("%s did not win (common).", msg.sender);
            rarity = "Common outcome - no prize";
		}

        waves.push(Wave(msg.sender, _message, block.timestamp, rarity));

        emit NewWave(msg.sender, block.timestamp, _message, rarity);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}
