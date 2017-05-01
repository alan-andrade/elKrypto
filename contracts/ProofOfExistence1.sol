pragma solidity ^0.4.4;

contract ProofOfExistence1 {
    bytes32 public proof;
    //^^^^^ size of a sha256

    // Write
    //
    // Mutates state therefore needs gas
    function notarize(string document) {
        proof = calculateProof(document);
    }

    // readonly
    //
    // When the function has a constant and returns something, it won't consume
    // gas.
    function calculateProof(string document) constant returns (bytes32) {
        return sha256(document);
    }
}
