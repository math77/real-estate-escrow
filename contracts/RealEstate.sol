//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";


//@author promatheus
contract RealEstate is ERC721 {

  uint256 private _tokenId;
  mapping(uint256 tokenId => string tokenURI) private _tokenURIs;

  constructor() ERC721("REAL ESTATE", "RE") {}

  function mint(string calldata tokenURI) public returns (uint256) {

    unchecked {
      _tokenURIs[++_tokenId] = tokenURI;
      _mint(msg.sender, _tokenId);
    }

    return _tokenId;
  }
  
}
