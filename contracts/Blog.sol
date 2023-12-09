// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    string public name;
    address public owner;

    struct Post {
        uint256 id;
        string title;
        string content;
        bool published;
    }

    mapping(uint256 => Post) private idToPost;
    mapping(string => Post) private hashToPost;
     modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }

    // we can create listeners for events in the client and use them in The Graph  
    event PostCreated(uint id, string title, string hash);
    event PostUpdated(uint id, string title, string hash, bool published);

    // setting the contract deployer as the owner
    constructor(string memory _name) {
        console.log("Deploying Blog with name:", _name);
        name = _name;
        owner = msg.sender;
    }

    function updateName(string memory _name) public {
        name = _name;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /* fetches an individual post by the content hash */
    function fetchPost(string memory hash) public view returns(Post memory){
      return hashToPost[hash];
    }

     function createPost(string memory title, string memory hash) public onlyOwner {
        _postIds.increment();
        uint postId = _postIds.current();
        Post storage post = idToPost[postId];
        post.id = postId;
        post.title = title;
        post.published = true;
        post.content = hash;
        hashToPost[hash] = post;
        emit PostCreated(postId, title, hash);
    }

    function updatePost(uint postId, string memory title, string memory hash, bool published) public onlyOwner {
        Post storage post =  idToPost[postId];
        post.title = title;
        post.published = published;
        post.content = hash;
        idToPost[postId] = post;
        hashToPost[hash] = post;
        emit PostUpdated(post.id, title, hash, published);
    }

     function fetchPosts() public view returns (Post[] memory) {
        uint itemCount = _postIds.current();
        uint currentIndex = 0;

        Post[] memory posts = new Post[](itemCount);
        //copying posts into the array;
        for (uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;
            Post storage currentItem = idToPost[currentId];
            posts[currentIndex] = currentItem;
            currentIndex += 1;
            posts[i] = currentItem;
        }
        return posts;
    }



}