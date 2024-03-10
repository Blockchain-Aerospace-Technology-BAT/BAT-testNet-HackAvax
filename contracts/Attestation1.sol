// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Attestation {

    // Estructura para almacenar los datos de atestación
    struct AttestationData {
        uint256 expiry;      // Fecha de expiración de la atestación
        bytes32 dataHash;    // Hash de los datos atestados
        bool valid;          // Si la atestación está actualmente válida o no
    }

    // Direccion del propietario del contrato (quien puede emitir atestaciones)
    address public owner;

    // Mapeo de direcciones a sus datos de atestación
    mapping(address => AttestationData) public attestations;

    // Eventos para emitir cuando se crea o revoca una atestación
    event AttestationIssued(address indexed user, bytes32 dataHash, uint256 expiry);
    event AttestationRevoked(address indexed user);

    constructor() {
        owner = msg.sender;  // El creador del contrato es el propietario
    }

    // Modificador para restringir funciones solo al propietario
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Función para emitir una nueva atestación
    function issueAttestation(address user, bytes32 dataHash, uint256 expiry) public onlyOwner {
        require(expiry > block.timestamp, "Expiry must be in the future");
        attestations[user] = AttestationData(expiry, dataHash, true);
        emit AttestationIssued(user, dataHash, expiry);
    }

    // Función para revocar una atestación
    function revokeAttestation(address user) public onlyOwner {
        attestations[user].valid = false;
        emit AttestationRevoked(user);
    }

    // Función para verificar la validez de una atestación
    function verifyAttestation(address user, bytes32 dataHash) public view returns (bool) {
        AttestationData memory attestation = attestations[user];
        return attestation.valid && attestation.dataHash == dataHash && attestation.expiry > block.timestamp;
    }
}

