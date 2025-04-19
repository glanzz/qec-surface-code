# Quantum Error Correction: Surface Code

The repository implements rotated surface code with MWPM algorithm for decoder.
We build a logical qubit, identify errors using error syndromes at each timestep and finally apply error correction on the data qubits. The logical qubit is measured to finally to know if error correction was successful.

## Objective
- Implement a d=3 surface code in Q# with separate layouts for data and ancilla qubits.
- Simulate Pauli noise (bit-flip, phase-flip) across multiple rounds of stabilizer cycles.
- Extract syndrome measurements and apply MWPM using a classical decoder.
- Visualize syndrome defects and correction paths for debugging and intuition.
- Assess logical qubit fidelity post-correction by varying physical error rates

## Workflow
![Workflow](/qec-highlevel.png)

# Components
- Surface Code Architecture in Q#
- Pauli Tracking Layer for syndrome measurements history
- Error detection at each timestep using Minimum-weight perfect matching decoder with error graphs
- Error correction on logical qubits




