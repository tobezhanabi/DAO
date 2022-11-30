// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FakeNFTMarketplace {
  //map fake token ID to owners address
  mapping(uint256 => address) public tokens;

  uint256 nftPrice = 0.1 ether;

  function purchase(uint256 _tokenId) external payable {
    //_tokenId fake nft token id to be purchase
    require(msg.value == nftPrice, "The price is 0.1 ether");
    tokens[_tokenId] = msg.sender;
  }

  function getPrice() external view returns (uint256) {
    return nftPrice;
  }

  function available(uint256 _tokenId) external view returns (bool) {
    if (tokens[_tokenId] == address(0)) {
      // address(0) = 0x00000000000000000000000000000; default value for address in solidity
      return true;
    }
    return false;
  }
}
