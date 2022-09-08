// SPDX-License-Identifier: MIT
pragma solidity ^0.5.6;

import "../contracts/klaytn-contracts/token/KIP7/IKIP7.sol";
import "../contracts/klaytn-contracts/token/KIP37/KIP37Mintable.sol";
import "../contracts/klaytn-contracts/math/SafeMath.sol";
import "../contracts/klaytn-contracts/ownership/Ownable.sol";
import "./ReentrancyGuard.sol";

contract ChickStore is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IKIP7 public Chick;

    constructor(IKIP7 _Chick) public {
        Chick = _Chick;
    }

    struct Product {
        uint256 id;
        address item;
        uint256 tokenId;
        uint256 price;
    }

    Product[] public ProductList;

    function totalProducts() public view returns (uint256) {
        return ProductList.length;
    }

    function addProduct(
        address _item,
        uint256 _tokenId,
        uint256 _price
    ) external onlyOwner {
        ProductList.push(
            Product({
                id: totalProducts(),
                item: _item,
                tokenId: _tokenId,
                price: _price
            })
        );
    }

    function modifyProductPrice(uint256 _id, uint256 _price)
        external
        onlyOwner
    {
        Product storage _product = ProductList[_id];
        _product.price = _price;
    }

    function buyProduct(uint256 _id, uint256 _quan) external nonReentrant {
        Product memory _product = ProductList[_id];
        KIP37Mintable Item_ = KIP37Mintable(_product.item);

        Chick.transferFrom(
            msg.sender,
            address(this),
            _quan.mul(_product.price)
        );

        Item_.mint(_product.tokenId, msg.sender, _quan);
    }

    function withdrawChick() external onlyOwner {
        Chick.transfer(msg.sender, Chick.balanceOf(address(this)));
    }
}
