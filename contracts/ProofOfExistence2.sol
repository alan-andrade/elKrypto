pragma solidity ^0.4.4;

contract ProofOfExistence2 {
    bytes32[] private proofs;

    function storeProof(bytes32 proof) {
        proofs.push(proof);
    }

    function notarize(string document) {
        var proof = calculateProof(document);
        storeProof(proof);
    }

    function checkDocument(string document) constant returns (bool) {
        var proof = calculateProof(document);
        return hasProof(proof);
    }

    function hasProof(bytes32 proof) constant returns (bool) {
        for(var i = 0; i < proofs.length; i++) {
            if (proofs[i] == proof) {
                return true;
            }
        }

        return false;
    }

    // readonly
    //
    // When the function has a constant and returns something, it won't consume
    // gas.
    function calculateProof(string document) constant returns (bytes32) {
        return sha256(document);
    }
}
