// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OnchainIPFS is ERC721, Ownable {
    struct File {
        string fileType;
        string content; // HEX encoded content or CID
        bool isFull;
        string txID;
        bool isTxAlone;
        string filename;
        string[] splitParts;
        string originalURL;
        string author;
        string title;
        bool isFolder;
        string[] folderCIDs;
        string sha3_512_CID;
        string originCID;
        string originCommand;
        string originCommandVersion;
    }

    uint256 public nextFileId = 0;
    mapping(uint256 => File) public files;
    mapping(string => uint256) public filenameToId;

    event FilePublished(uint256 indexed fileId, address indexed owner, string cid);
    event TitleAdded(uint256 indexed fileId, string title);
    event FilenameAdded(uint256 indexed fileId, string filename);
    event AuthorAdded(uint256 indexed fileId, string author);

    constructor() ERC721("OnchainIPFS", "OIPFS") {}

    function publishFile(
        string memory _fileType,
        string memory _content,
        bool _isFull,
        string memory _txID,
        bool _isTxAlone,
        string memory _filename,
        string[] memory _splitParts,
        string memory _originalURL,
        string memory _author,
        bool _isFolder,
        string[] memory _folderCIDs,
        string memory _sha3_512_CID,
        string memory _originCID,
        string memory _originCommand,
        string memory _originCommandVersion
    ) public {
        // Validate the CIDs
        require(validateCID(_content), "Invalid CID");
        if (bytes(_originCID).length > 0) {
            require(validateCID(_originCID), "Invalid origin CID");
            require(bytes(_originCommand).length > 0, "Origin command required");
            require(bytes(_originCommandVersion).length > 0, "Origin command version required");
        }
        require(validateSHA3_512CID(_sha3_512_CID), "Invalid SHA3-512 CID");

        uint256 fileId = nextFileId;
        files[fileId] = File({
            fileType: _fileType,
            content: _content,
            isFull: _isFull,
            txID: _txID,
            isTxAlone: _isTxAlone,
            filename: _filename,
            splitParts: _splitParts,
            originalURL: _originalURL,
            author: _author,
            title: "",
            isFolder: _isFolder,
            folderCIDs: _isFolder ? _folderCIDs : new string[](0),
            sha3_512_CID: _sha3_512_CID,
            originCID: _originCID,
            originCommand: _originCommand,
            originCommandVersion: _originCommandVersion
        });

        if (bytes(_filename).length > 0) {
            filenameToId[_filename] = fileId;
        }

        _mint(msg.sender, fileId);
        nextFileId++;

        emit FilePublished(fileId, msg.sender, _content);
    }

    function addTitle(uint256 _fileId, string memory _title) public {
        require(ownerOf(_fileId) == msg.sender, "Only the owner can add a title");
        require(bytes(files[_fileId].title).length == 0, "Title already set");
        files[_fileId].title = _title;

        emit TitleAdded(_fileId, _title);
    }

    function addFilename(uint256 _fileId, string memory _filename) public {
        require(ownerOf(_fileId) == msg.sender, "Only the owner can add a filename");
        require(bytes(files[_fileId].filename).length == 0, "Filename already set");
        files[_fileId].filename = _filename;
        filenameToId[_filename] = _fileId;

        emit FilenameAdded(_fileId, _filename);
    }

    function addAuthor(uint256 _fileId, string memory _author) public {
        require(ownerOf(_fileId) == msg.sender, "Only the owner can add an author");
        require(bytes(files[_fileId].author).length == 0, "Author already set");
        files[_fileId].author = _author;

        emit AuthorAdded(_fileId, _author);
    }

    function getFile(uint256 _fileId) public view returns (File memory) {
        return files[_fileId];
    }

    function getFileByFilename(string memory _filename) public view returns (File memory) {
        uint256 fileId = filenameToId[_filename];
        return files[fileId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        File memory file = files[tokenId];

        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
            '<style>@import url("https://fonts.googleapis.com/css2?family=Roboto");</style>',
            '<rect width="100%" height="100%" fill="white" />',
            '<text x="10" y="20" font-family="Roboto" font-size="16" fill="black">',
            'ID: ', toString(tokenId), '</text>',
            '<text x="10" y="40" font-family="Roboto" font-size="16" fill="black">',
            'Filename: ', file.filename, '</text>',
            '<text x="10" y="60" font-family="Roboto" font-size="16" fill="black">',
            'CID: ', file.content, '</text>',
            file.isFolder ? '<text x="10" y="80" font-family="Roboto" font-size="16" fill="black">Folder: Yes</text>' : '',
            '</svg>'
        ));

        string memory json = string(abi.encodePacked(
            '{"name": "Onchain IPFS #', toString(tokenId), '", ',
            '"description": "An onchain IPFS file stored on Ethereum.", ',
            '"image": "data:image/svg+xml;base64,', base64(bytes(svg)), '", ',
            '"attributes": [{',
                '"trait_type": "File Type", "value": "', file.fileType, '"}, {',
                '"trait_type": "Filename", "value": "', file.filename, '"}, {',
                '"trait_type": "Author", "value": "', file.author, '"}, {',
                '"trait_type": "Title", "value": "', file.title, '"}, {',
                '"trait_type": "CID", "value": "', file.content, '"}, {',
                '"trait_type": "SHA3-512 CID", "value": "', file.sha3_512_CID, '"}, {',
                '"trait_type": "Origin CID", "value": "', file.originCID, '"}, {',
                '"trait_type": "Origin Command", "value": "', file.originCommand, '"}, {',
                '"trait_type": "Origin Command Version", "value": "', file.originCommandVersion, '"}, {',
                '"trait_type": "Folder", "value": "', file.isFolder ? "Yes" : "No", '"}]}'
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
        bytes memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        bytes memory result = new bytes(4 * ((data.length + 2) / 3));
        for (uint256 i = 0; i < data.length; i += 3) {
            uint256 a = uint8(data[i]);
            uint256 b = i + 1 < data.length ? uint8(data[i + 1]) : 0;
            uint256 c = i + 2 < data.length ? uint8(data[i + 2]) : 0;
            result[i / 3 * 4] = alphabet[a >> 2];
            result[i / 3 * 4 + 1] = alphabet[(a & 3) << 4 | b >> 4];
            result[i / 3 * 4 + 2] = i + 1 < data.length ? alphabet[(b & 15) << 2 | c >> 6] : "=";
            result[i / 3 * 4 + 3] = i + 2 < data.length ? alphabet[c & 63] : "=";
        }
        return string(result);
    }

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
}
