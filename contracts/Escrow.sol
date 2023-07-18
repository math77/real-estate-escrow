//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;


import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Escrow {


  address private _nftAddress;
  uint256 private _nftID;
  uint256 private _purchasePrice;
  uint256 private _escrowAmount;
  address payable private _buyer;
  address payable private _seller;
  address private _inspector;
  address private _lender;

  bool public inspectionPassed;
  mapping(address => bool) private _approval;


  error OnlyBuyer();
  error OnlySeller();
  error OnlyInspector();
  error InspectionNotPassed();
  error BuyerNotApproved();
  error SellerNotApproved();
  error LenderNotApproved();
  error PurchasePriceTooHigh();


  modifier onlyBuyer() { 
    if (msg.sender != _buyer) revert OnlyBuyer();
    _;
  }

  modifier onlySeller() {
    if (msg.sender != _seller) revert OnlySeller();
    _;
  }

  modifier onlyInspector() {
    if (msg.sender != _inspector) revert OnlyInspector();
    _;
  }
  
  receive() external payable {}

  constructor(
    address nftAddress,
    uint256 nftID,
    uint256 purchasePrice,
    uint256 escrowAmount,
    address payable seller,
    address payable buyer,
    address inspector,
    address lender
    ) {

      _nftAddress = nftAddress;
      _nftID = nftID;
      _purchasePrice = purchasePrice;
      _escrowAmount = escrowAmount;
      _seller = seller;
      _buyer = buyer;
      _inspector = inspector;
      _lender = lender;
  }

  function updateInspectionStatus(bool passed) public onlyInspector {
    inspectionPassed = passed;
  }

  function approveSale() public {
    _approval[msg.sender] = true;
  }

  function finalizeSale() public {
    if (!inspectionPassed) revert InspectionNotPassed();
    if (!_approval[_buyer]) revert BuyerNotApproved();
    if (!_approval[_seller]) revert SellerNotApproved();
    if (!_approval[_lender]) revert LenderNotApproved();
    if (_purchasePrice > address(this).balance) revert PurchasePriceTooHigh();

    (bool success, ) = payable(_seller).call{value: address(this).balance}("");
    if (!success) revert ("pay seller error");

    IERC721(_nftAddress).transferFrom(_seller, _buyer, _nftID);

  }

  function cancelSale() public {
    address transferTo = inspectionPassed ? _seller : _buyer;
    payable(transferTo).transfer(address(this).balance);
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
}
