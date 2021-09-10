// I wanted to have a punk, but they were too expensive. 
// so I created these ApePunk. Our goal is to witness the bright future of NFT through ten years.
// Please call me, distant guide.
pragma solidity ^0.8.0;

contract RiseofthePlanetoftheApes is Ownable, ERC721Enumerable, ReentrancyGuard {
  using Counters for Counters.Counter;
  using Strings for uint256;

  string public imageHash;

  bool public isSaleOn = false;

  bool public saleHasBeenStarted = false;

  uint256 public constant MAX_MINTABLE_AT_ONCE = 20;

  uint256 private _price = 0.02021 ether; // 20210000000000000
  
  string public punkcontractURI;
  
  constructor() ERC721("RiseofthePlanetoftheApes", "ApePunk") {}

  // for wd
  address oaf = 0x1Ca6D07D237a9f92c7ed3Ea7e88f383Ae52e4a70;
  address quack = 0xc0E7Ab60CE872346221572Dda73A279485b1ee44;

  uint256[10000] private _availableTokens;
  
  uint256 private _numAvailableTokens = 10000;
  
  uint256 private _lastTokenIdMintedInInitialSet = 10000;

  function numTotalPunks() public view virtual returns (uint256) {
    return 10000;
  }


  function mint(uint256 _numToMint) public payable nonReentrant() {
    require(isSaleOn, "Sale hasn't started.");
    uint256 totalSupply = totalSupply();
    require(
      totalSupply + _numToMint <= numTotalPunks(),
      "There are not this many punks left."
    );
    uint256 costForMintingPunks = _price * _numToMint;
    require(
      msg.value >= costForMintingPunks,
      "Too little sent, please send more eth."
    );
    if (msg.value > costForMintingPunks) {
      payable(msg.sender).transfer(msg.value - costForMintingPunks);
    }

    _mint(_numToMint);
  }

  // internal minting function
  function _mint(uint256 _numToMint) internal {
    require(_numToMint <= MAX_MINTABLE_AT_ONCE, "Minting too many at once.");

    uint256 updatedNumAvailableTokens = _numAvailableTokens;
    for (uint256 i = 0; i < _numToMint; i++) {
      uint256 newTokenId = useRandomAvailableToken(_numToMint, i);
      _safeMint(msg.sender, newTokenId);
      updatedNumAvailableTokens--;
    }
    _numAvailableTokens = updatedNumAvailableTokens;
  }
  

  function useRandomAvailableToken(uint256 _numToFetch, uint256 _i)
    internal
    returns (uint256)
  {
    uint256 randomNum =
      uint256(
        keccak256(
          abi.encode(
            msg.sender,
            tx.gasprice,
            block.number,
            block.timestamp,
            blockhash(block.number - 1),
            _numToFetch,
            _i
          )
        )
      );
    uint256 randomIndex = randomNum % _numAvailableTokens;
    return useAvailableTokenAtIndex(randomIndex);
  }

  function useAvailableTokenAtIndex(uint256 indexToUse)
    internal
    returns (uint256)
  {
    uint256 valAtIndex = _availableTokens[indexToUse];
    uint256 result;
    if (valAtIndex == 0) {
      // This means the index itself is still an available token
      result = indexToUse;
    } else {
      // This means the index itself is not an available token, but the val at that index is.
      result = valAtIndex;
    }

    uint256 lastIndex = _numAvailableTokens - 1;
    if (indexToUse != lastIndex) {
      // Replace the value at indexToUse, now that it's been used.
      // Replace it with the data from the last index in the array, since we are going to decrease the array size afterwards.
      uint256 lastValInArray = _availableTokens[lastIndex];
      if (lastValInArray == 0) {
        // This means the index itself is still an available token
        _availableTokens[indexToUse] = lastIndex;
      } else {
        // This means the index itself is not an available token, but the val at that index is.
        _availableTokens[indexToUse] = lastValInArray;
      }
    }

    _numAvailableTokens--;
    return result;
  }
  
  function reserveApePunks0() public onlyOwner {        
        uint supply = totalSupply();
        uint i;
        for (i = 0; i < 33; i++) {
            _safeMint(msg.sender, supply + i);
        }
  }

  function reserveApePunks2() public onlyOwner {        
        uint supply = totalSupply();
        uint i;
        for (i = 0; i < 99; i++) {
            _safeMint(msg.sender, supply + i);
        }
  }

  function getPrice() public view returns (uint256){
    return _price;
  }

  function contractURI() public view returns (string memory){
    return punkcontractURI;
  }


  function getCostForMintingPunks(uint256 _numToMint)
    public
    view
    returns (uint256)
  {
    require(
      totalSupply() + _numToMint <= numTotalPunks(),
      "There are not this many punks left."
    );
    require(
      _numToMint <= MAX_MINTABLE_AT_ONCE,
      "You cannot mint that many punks."
    );
    return _numToMint * _price;  
  }

  function getPunksBelongingToOwner(address _owner)
    external
    view
    returns (uint256[] memory)
  {
    uint256 numPunks = balanceOf(_owner);
    if (numPunks == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](numPunks);
      for (uint256 i = 0; i < numPunks; i++) {
        result[i] = tokenOfOwnerByIndex(_owner, i);
      }
      return result;
    }
  }

  /*
   * Dev stuff.
   */

  // metadata URI
  string private _baseTokenURI;

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    string memory base = _baseURI();
    string memory _tokenURI = Strings.toString(_tokenId);
    string memory ending = ".json";

    // If there is no base URI, return the token URI.
    if (bytes(base).length == 0) {
      return _tokenURI;
    }

    return string(abi.encodePacked(base, _tokenURI, ending));
  }
  

  /*
   * Owner stuff
   */

    // In case of catastrophic ETH movement

  function setPrice(uint256 _newPrice) public onlyOwner() {
    _price = _newPrice;
  }

  function startSale() public onlyOwner {
    isSaleOn = true;
    saleHasBeenStarted = true;
  }

  function endSale() public onlyOwner {
    isSaleOn = false;
  }


  // URIs
  function setBaseURI(string memory baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function setContractURI(string memory _contractURI) external onlyOwner {
    punkcontractURI = _contractURI;
  }
  
    function setImageHash(string memory _imageHash) external onlyOwner {
    imageHash = _imageHash;
  }

    function withdrawTeam() public onlyOwner {
    //uint256 _each = address(this).balance / 4;
    // uint256 _sixp = .06;
    uint256 _balance = address(this).balance;
    uint256 _oaf = _balance / 100 * 6;
    uint256 _quack = _balance - _oaf;
    require(payable(oaf).send(_oaf));
    require(payable(quack).send(_quack));
  }
  
    function withdrawFailsafe() public onlyOwner {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override(ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}