// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OnchainIPFS is ERC721, Ownable {
    struct FileMetadata {
        string fileType;
        bool isFull;
        string txID;
        bool isTxAlone;
        string filename;
        string originalURL;
        string author;
        string title;
        bool isFolder;
    }

    struct FileContent {
        string content; // HEX encoded content or CID
        string[] splitParts;
        string[] folderCIDs;
        string sha3_512_CID;
        string originCID;
        string originCommand;
        string originCommandVersion;
    }

    uint256 public nextFileId = 0;
    mapping(uint256 => FileMetadata) public filesMetadata;
    mapping(uint256 => FileContent) public filesContent;
    mapping(string => uint256) public filenameToId;

    event FilePublished(uint256 indexed fileId, address indexed owner, string cid);
    event TitleAdded(uint256 indexed fileId, string title);
    event FilenameAdded(uint256 indexed fileId, string filename);
    event AuthorAdded(uint256 indexed fileId, string author);

    constructor() ERC721("OnchainIPFS", "OIPFS") Ownable(msg.sender) {}

    function validateCID(string memory cid) internal pure returns (bool) {
        bytes memory cidBytes = bytes(cid);
        // Basic length check for IPFS CID
        if (cidBytes.length != 46) {
            return false;
        }
        // Check if CID starts with 'Qm' (for IPFS v0 CIDs)
        if (cidBytes[0] != 'Q' || cidBytes[1] != 'm') {
            return false;
        }
        return true;
    }

    function validateSHA3_512CID(string memory cid) internal pure returns (bool) {
        bytes memory cidBytes = bytes(cid);
        // Check if CID starts with 'bafkriq'
        if (cidBytes.length < 7) {
            return false;
        }
        for (uint256 i = 0; i < 7; i++) {
            if (cidBytes[i] != bytes("bafkriq")[i]) {
                return false;
            }
        }
        return true;
    }

    function publishFile(FileMetadata memory metadata, FileContent memory content) public {
        require(validateCID(content.content), "Invalid CID");
        if (bytes(content.originCID).length > 0) {
            require(validateCID(content.originCID), "Invalid origin CID");
            require(bytes(content.originCommand).length > 0, "Origin command required");
            require(bytes(content.originCommandVersion).length > 0, "Origin command version required");
        }
        require(validateSHA3_512CID(content.sha3_512_CID), "Invalid SHA3-512 CID");

        uint256 fileId = nextFileId;
        filesMetadata[fileId] = metadata;
        filesContent[fileId] = content;

        nextFileId++;

        _mint(msg.sender, fileId);

        emit FilePublished(fileId, msg.sender, content.content);
    }

    function addTitle(uint256 fileId, string memory title) public {
        require(ownerOf(fileId) == msg.sender, "Not the owner");
        require(bytes(filesMetadata[fileId].title).length == 0, "Title already added");

        filesMetadata[fileId].title = title;

        emit TitleAdded(fileId, title);
    }

    function addFilename(uint256 fileId, string memory filename) public {
        require(ownerOf(fileId) == msg.sender, "Not the owner");
        require(bytes(filesMetadata[fileId].filename).length == 0, "Filename already added");

        filesMetadata[fileId].filename = filename;
        filenameToId[filename] = fileId;

        emit FilenameAdded(fileId, filename);
    }

    function addAuthor(uint256 fileId, string memory author) public {
        require(ownerOf(fileId) == msg.sender, "Not the owner");
        require(bytes(filesMetadata[fileId].author).length == 0, "Author already added");

        filesMetadata[fileId].author = author;

        emit AuthorAdded(fileId, author);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");

        FileMetadata memory fileMetadata = filesMetadata[tokenId];
        FileContent memory fileContent = filesContent[tokenId];

        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
            '<style>@import url("https://fonts.googleapis.com/css2?family=Roboto");</style>',
            '<rect width="100%" height="100%" fill="white" />',
            '<text x="10" y="20" font-family="Roboto" font-size="16" fill="black">',
            'ID: ', toString(tokenId), '</text>',
            '<text x="10" y="40" font-family="Roboto" font-size="16" fill="black">',
            'Filename: ', fileMetadata.filename, '</text>',
            '<text x="10" y="60" font-family="Roboto" font-size="16" fill="black">',
            'CID: ', fileContent.content, '</text>',
            fileMetadata.isFolder ? '<text x="10" y="80" font-family="Roboto" font-size="16" fill="black">Folder: Yes</text>' : '',
            '</svg>'
        ));

        string memory json = string(abi.encodePacked(
            '{"name": "Onchain IPFS #', toString(tokenId), '", ',
            '"description": "An onchain IPFS file stored on Ethereum.", ',
            '"image": "data:image/svg+xml;base64,', base64(bytes(svg)), '", ',
            '"attributes": [{',
                '"trait_type": "File Type", "value": "', fileMetadata.fileType, '"}, {',
                '"trait_type": "Filename", "value": "', fileMetadata.filename, '"}, {',
                '"trait_type": "Author", "value": "', fileMetadata.author, '"}, {',
                '"trait_type": "Title", "value": "', fileMetadata.title, '"}, {',
                '"trait_type": "CID", "value": "', fileContent.content, '"}, {',
                '"trait_type": "SHA3-512 CID", "value": "', fileContent.sha3_512_CID, '"}, {',
                '"trait_type": "Origin CID", "value": "', fileContent.originCID, '"}, {',
                '"trait_type": "Origin Command", "value": "', fileContent.originCommand, '"}, {',
                '"trait_type": "Origin Command Version", "value": "', fileContent.originCommandVersion, '"}, {',
                '"trait_type": "Folder", "value": "', fileMetadata.isFolder ? "Yes" : "No", '"}]}'
        ));

        return string(abi.encodePacked('data:application/json;base64,', base64(bytes(json))));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function base64(bytes memory data) internal pure returns (string memory) {
        bytes memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 len = data.length;
        if (len == 0) return '';

        uint256 encodedLen = 4 * ((len + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory tablePtr;
        assembly {
            tablePtr := add(table, 1)
        }

        uint256 i = 0;
        uint256 j = 0;
        uint256 r = len % 3;
        for (; i < len - r; i += 3) {
            uint256 a = uint8(data[i]);
            uint256 b = uint8(data[i+1]);
            uint256 c = uint8(data[i+2]);
            uint256 triple = (a << 16) | (b << 8) | c;

            assembly {
                mstore8(add(result, j), mload(add(tablePtr, and(shr(18, triple), 0x3F))))
                mstore8(add(result, add(j, 1)), mload(add(tablePtr, and(shr(12, triple), 0x3F))))
                mstore8(add(result, add(j, 2)), mload(add(tablePtr, and(shr(6, triple), 0x3F))))
                mstore8(add(result, add(j, 3)), mload(add(tablePtr, and(triple, 0x3F))))
            }
            j += 4;
        }

        if (r > 0) {
            uint256 a = uint8(data[i]);
            uint256 b = r == 2 ? uint8(data[i+1]) : 0;
            uint256 triple = (a << 16) | (b << 8);

            assembly {
                mstore8(add(result, j), mload(add(tablePtr, and(shr(18, triple), 0x3F))))
                mstore8(add(result, add(j, 1)), mload(add(tablePtr, and(shr(12, triple), 0x3F))))
                mstore8(add(result, add(j, 2)), mload(add(tablePtr, and(shr(6, triple), 0x3F))))
                mstore8(add(result, add(j, 3)), 0x3d)
            }
        }

        assembly {
            mstore(result, encodedLen)
        }

        return string(result);
    }
}

