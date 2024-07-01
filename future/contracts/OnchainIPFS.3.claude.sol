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

    constructor(address initialOwner) ERC721("OnchainIPFS", "OIPFS") Ownable(initialOwner) {}

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

        if (bytes(metadata.filename).length > 0) {
            filenameToId[metadata.filename] = fileId;
        }

        _mint(msg.sender, fileId);
        nextFileId++;

        emit FilePublished(fileId, msg.sender, content.content);
    }

    function addTitle(uint256 _fileId, string memory _title) public {
        require(ownerOf(_fileId) == msg.sender, "Only the owner can add a title");
        require(bytes(filesMetadata[_fileId].title).length == 0, "Title already set");
        filesMetadata[_fileId].title = _title;
        emit TitleAdded(_fileId, _title);
    }

    function addFilename(uint256 _fileId, string memory _filename) public {
        require(ownerOf(_fileId) == msg.sender, "Only the owner can add a filename");
        require(bytes(filesMetadata[_fileId].filename).length == 0, "Filename already set");
        filesMetadata[_fileId].filename = _filename;
        filenameToId[_filename] = _fileId;
        emit FilenameAdded(_fileId, _filename);
    }

    function addAuthor(uint256 _fileId, string memory _author) public {
        require(ownerOf(_fileId) == msg.sender, "Only the owner can add an author");
        require(bytes(filesMetadata[_fileId].author).length == 0, "Author already set");
        filesMetadata[_fileId].author = _author;
        emit AuthorAdded(_fileId, _author);
    }

    function getFileMetadata(uint256 _fileId) public view returns (FileMetadata memory) {
        return filesMetadata[_fileId];
    }

    function getFileContent(uint256 _fileId) public view returns (FileContent memory) {
        return filesContent[_fileId];
    }

    function getFileByFilename(string memory _filename) public view returns (FileMetadata memory, FileContent memory) {
        uint256 fileId = filenameToId[_filename];
        return (filesMetadata[fileId], filesContent[fileId]);
    }

    function validateCID(string memory cid) internal pure returns (bool) {
        bytes memory cidBytes = bytes(cid);
        if (cidBytes.length != 46) {
            return false;
        }
        if (cidBytes[0] != "Q" || cidBytes[1] != "m") {
            return false;
        }
        return true;
    }

    function validateSHA3_512CID(string memory cid) internal pure returns (bool) {
        bytes memory cidBytes = bytes(cid);
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

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );

        FileMetadata memory metadata = filesMetadata[tokenId];
        FileContent memory content = filesContent[tokenId];

        string memory json = string(abi.encodePacked(
            '{"name": "Onchain IPFS #', toString(tokenId), '", ',
            '"description": "An onchain IPFS file stored on Ethereum.", ',
            '"attributes": [',
            '{"trait_type": "File Type", "value": "', metadata.fileType, '"}, ',
            '{"trait_type": "Filename", "value": "', metadata.filename, '"}, ',
            '{"trait_type": "Author", "value": "', metadata.author, '"}, ',
            '{"trait_type": "Title", "value": "', metadata.title, '"}, ',
            '{"trait_type": "CID", "value": "', content.content, '"}, ',
            '{"trait_type": "SHA3-512 CID", "value": "', content.sha3_512_CID, '"}, ',
            '{"trait_type": "Origin CID", "value": "', content.originCID, '"}, ',
            '{"trait_type": "Origin Command", "value": "', content.originCommand, '"}, ',
            '{"trait_type": "Origin Command Version", "value": "', content.originCommandVersion, '"}, ',
            '{"trait_type": "Folder", "value": "', metadata.isFolder ? "Yes" : "No", '"}',
            ']}'
        ));

        return string(abi.encodePacked("data:application/json;base64,", base64(bytes(json))));
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
        string memory TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
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

        if (r == 1) {
            uint256 a = uint8(data[i]);
            assembly {
                mstore8(add(result, j), mload(add(tablePtr, and(shr(2, a), 0x3F))))
                mstore8(add(result, add(j, 1)), mload(add(tablePtr, and(shl(4, a), 0x3F))))
                mstore8(add(result, add(j, 2)), 0x3d3d)
            }
        } else if (r == 2) {
            uint256 a = uint8(data[i]);
            uint256 b = uint8(data[i+1]);
            uint256 triple = (a << 8) | b;
            assembly {
                mstore8(add(result, j), mload(add(tablePtr, and(shr(10, triple), 0x3F))))
                mstore8(add(result, add(j, 1)), mload(add(tablePtr, and(shr(4, triple), 0x3F))))
                mstore8(add(result, add(j, 2)), mload(add(tablePtr, and(shl(2, triple), 0x3F))))
                mstore8(add(result, add(j, 3)), 0x3d)
            }
        }

        return string(result);
    }
}
