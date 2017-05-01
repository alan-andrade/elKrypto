pragma solidity ^0.4.4;

contract ProofOfExistence3 {
    mapping(bytes32 => bool) private proofs;

    function storeProof(bytes32 proof) {
        proofs[proof] = true;
    }

    function notarize(string document) {
        var proof = calculateProof(document);
        storeProof(proof);
    }

    function checkDocument(string document) constant returns (bool) {
        var proof = calculateProof(document);
        return proofs[proof];
    }

    function calculateProof(string document) constant returns (bytes32) {
        return sha256(document);
    }
}
