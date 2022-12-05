pragma solidity ^0.8.17; // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract thewall is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 initLikes=0;
    uint256 initDonaciones=0;
    uint256 initMensajes=0;
    struct nft {
        uint256 tokenid;
        string name;
        address payable owner;
        string tokenuri;
        uint8[] pixels;
        uint16[2] size;
        string[] colors;
    }

    struct nftextra {
        uint256 tokenid;
        uint256 totLikes;
        uint256 totDonaciones;
        uint256 totMensajes;
    }

     struct donacion {
        string mensaje;
        uint256 donacion;
    }
 
    nft[] internal NFTcollection;
    nftextra[] internal NFTcollectionExtra;
    mapping(uint256 => donacion[]) private donaciones;
    
    constructor() ERC721("TheWall", "V1.3") {}

    function mint(
        address payable wallet,
        string memory tokenURI,
        string memory _name,
        uint8[] memory _pixels, 
        uint16[2] memory _size, 
        string[] memory _colors
    ) public  returns (uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(wallet, newItemId);
        _setTokenURI(newItemId, tokenURI);
        NFTcollection.push(nft({tokenid:newItemId, name:_name ,owner:wallet,tokenuri:tokenURI, pixels:_pixels ,size: _size,colors:_colors }));

        NFTcollectionExtra.push(nftextra({tokenid:newItemId, totLikes:initLikes ,totDonaciones:initDonaciones,totMensajes:initMensajes }));
        return newItemId;
    }

    function like(uint256 tokenid) public
    {
        require(_exists(tokenid), "Token inexistente");
        NFTcollectionExtra[tokenid-1].totLikes+=1;

    }

     function donar(uint256 tokenid,string memory _mensaje) public payable
    {
        uint256 ethers=msg.value;
        require(_exists(tokenid), "Token inexistente");
        require(ethers>0, "Debes enviar una cantidad de ether");
        address payable addressTo=NFTcollection[tokenid-1].owner;

        require(msg.sender!=addressTo, "Emisor y receptor no pueden ser el mismo");
        addressTo.transfer(msg.value);

        NFTcollectionExtra[tokenid-1].totDonaciones+=msg.value;
        donaciones[tokenid].push(donacion({mensaje:_mensaje,donacion:ethers}));

        bytes memory mensajeCheck = bytes(_mensaje); 
        if (mensajeCheck.length != 0) 
        NFTcollectionExtra[tokenid-1].totMensajes+=1;
 
    }

    function GetTokenSMS(uint256 tokenid) public view returns (donacion[] memory) {
        require(_exists(tokenid), "Token inexistente");
        return donaciones[tokenid];
    } 

    function GetTokenPixels() public view returns (nft[] memory) {
       return NFTcollection;
    } 
    function GetTokenExtra() public view returns (nftextra[] memory) {
       return NFTcollectionExtra;
    } 

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
        address payable toPayable = payable(to);
        NFTcollection[tokenId-1].owner=toPayable;
        
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _transfer(from, to, tokenId);
        address payable toPayable = payable(to);
        NFTcollection[tokenId-1].owner=toPayable;
    }

 
}


