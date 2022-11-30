// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {
  function getPrice() external view returns (uint256);

  function available(uint256 _tokenId) external view returns (bool);

  function purchase(uint256 _tokenId) external payable;
}

interface ICryptoDevNFT {
  function balanceOf(address owner) external view returns (uint256);

  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  ) external view returns (uint256);
}

contract CryptoDevDAO is Ownable {
  struct Proposal {
    uint256 nftTokenId;
    uint256 deadline;
    uint256 yayVotes;
    uint256 nayVotes;
    bool executed;
    // map tokenid to if they have voted or not
    mapping(uint256 => bool) voters;
  }
  // map for the proposals
  mapping(uint256 => Proposal) public proposals;
  // Number of proposals that have been created
  uint256 public numProposals;

  //initialiazing interface
  IFakeNFTMarketplace nftMarketplace;
  ICryptoDevNFT cryptoDevNFT;

  constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
    nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
    cryptoDevNFT = ICryptoDevNFT(_cryptoDevsNFT);
  }

  /////EVENTS////
  enum Vote {
    YAY,
    NAY
  }

  ///////MODIFIER///////
  modifier nftHolderOnly() {
    require(
      cryptoDevNFT.balanceOf(msg.sender) > 0,
      "Not a holder, Not a member"
    );
    _;
  }

  modifier activeProposalOnly(uint256 proposalIndex) {
    require(
      proposals[proposalIndex].deadline > block.timestamp,
      "DEADLINE PASSED"
    );
    _;
  }

  modifier inactiveProposalOnly(uint256 proposalIndex) {
    require(
      proposals[proposalIndex].deadline <= block.timestamp,
      "deadline not exceed"
    );
    require(
      proposals[proposalIndex].executed == false,
      "proposal already executed"
    );
    _;
  }

  function createProposal(
    uint256 _nftTokenId
  ) external nftHolderOnly returns (uint256) {
    //the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
    require(nftMarketplace.available(_nftTokenId), "NFT not for sell");
    Proposal storage proposal = proposals[numProposals];
    proposal.nftTokenId = _nftTokenId;
    proposal.deadline = block.timestamp + 5 minutes;

    numProposals++;
    return numProposals - 1;
  }

  function voteOnProposal(
    uint256 proposalIndex,
    Vote vote
  ) external nftHolderOnly activeProposalOnly(proposalIndex) {
    Proposal storage proposal = proposals[proposalIndex];

    uint256 voterNFTBalance = cryptoDevNFT.balanceOf(msg.sender);

    uint256 numVotes = 0;
    for (uint256 i = 0; i < voterNFTBalance; i++) {
      uint256 tokenId = cryptoDevNFT.tokenOfOwnerByIndex(msg.sender, i);
      if (proposal.voters[tokenId] == false) {
        numVotes++;
        proposal.voters[tokenId] = true;
      }
    }
    require(numVotes > 0, "Already voted");
    if (vote == Vote.YAY) {
      proposal.yayVotes += numVotes;
    } else {
      proposal.nayVotes += numVotes;
    }
  }

  function executeProposal(
    uint256 proposalIndex
  ) external nftHolderOnly inactiveProposalOnly(proposalIndex) {
    Proposal storage proposal = proposals[proposalIndex];

    if (proposal.yayVotes > proposal.nayVotes) {
      uint256 nftPrice = nftMarketplace.getPrice();
      require(address(this).balance >= nftPrice, "not enough funds");
      nftMarketplace.purchase{ value: nftPrice }(proposal.nftTokenId);
    }
    proposal.executed = true;
  }

  function withdrawEther() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  receive() external payable {}

  fallback() external payable {}
}
