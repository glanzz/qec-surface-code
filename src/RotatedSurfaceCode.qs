import Std.ResourceEstimation.MeasurementCount;
import Std.Arrays.ForEach;
import Std.Diagnostics.ConfigurePauliNoise;

import Std.Diagnostics.DumpMachine;
import Std.Convert.IntAsDouble;
import Std.Convert.DoubleAsStringWithPrecision;
import Std.Diagnostics.DumpRegister;
import SurfaceCode.MeasureXStabilizers;

  function validIndex(d: Int, index:Int): Bool {
    if 0 <= index and index < d*d {
      return true;
    }
    return false;
  }

operation MeasureLogicalZ(d: Int, dataQubits: Qubit[]): Result {
    // Logical Z is assumed to be a product of physical Zs on a vertical line
    // Choose the first column: index i*d for i in 0..d-1
    let results = MeasureEachZ(dataQubits);
    mutable parity = Zero;
    
    for res in results {
        if res == One {
            set parity = if (parity == Zero) { One } else { Zero };
        }
    }
    return parity;
}

  operation XStabilizer(indexes: Int[], dataQubits: Qubit[], q: Qubit): Unit {
    Reset(q);
    H(q);
    for index in indexes {
      // if (validIndex(d, index)) {
        CX(q, dataQubits[index]);
      // }
    }
    H(q);
  }

  operation ZStabilizer(indexes: Int[], dataQubits: Qubit[], q:Qubit): Unit {
    Reset(q);
    for index in indexes {
      // if (validIndex(d, index)) {
        CX( dataQubits[index], q);
      // }
    }
  }


  operation GetMaps(d: Int): (Int[][], Int[][]) {
    let TOTAL_DATA_QUBITS = d*d;
    mutable xMaps = [];
    mutable zMaps = [];
    mutable isZ = true;
    for i in 0..d-2 {
    for j in 0..d-2 {
      let id = (i*d)+j;
      if (i == 0)  and (j % 2 == 0) {
        let indexes = [id, id+1];
        xMaps += [indexes];
      }
      if (i%2 == 1)  and (j == 0) {
        let indexes = [id, id+d];
        zMaps += [indexes];
      }

      let indexes = [id, id+1, id+d, id+d+1];
      if (isZ) {
        zMaps += [indexes];
      } else {
        xMaps += [indexes];
      }
      
      if j != d-2 {
        set isZ = not isZ;
      }


      if (j == d-2)  and (i % 2 == 0) {
        let indexes = [id+1, id+d+1];
        zMaps += [indexes];
      }
    }
  }
  for j in 0..d-2 {
    if (j % 2 == 1) {
        let id = ((d-1)*d)+j;
        let indexes = [id, id+1];
        xMaps += [indexes];
      }
  }
  return (xMaps, zMaps);
  }

operation GenerateLattice(xMaps: Int[][], zMaps: Int[][], qubits: Qubit[], ancillaX: Qubit[], ancillaZ: Qubit[]): Unit {
  for i in 0..Length(xMaps)-1 {
    XStabilizer(xMaps[i], qubits, ancillaX[i]);
  }
  for j in 0..Length(xMaps)-1 {
    ZStabilizer(zMaps[j], qubits, ancillaZ[j]);
  }
}

operation GetSyndroem(initX: Result[], currX:Result[], initZ: Result[], currZ: Result[]): (Bool[], Bool[]) {
  mutable xSyndrome = [];
  mutable zSyndrome = [];
  for i in 0..Length(initX)-1 {
    xSyndrome += [initX[i] != currX[i]];
    if xSyndrome[i] {
      Message("Found X error at " + DoubleAsStringWithPrecision(IntAsDouble(i), 1))
    }
  }
  for i in 0..Length(initZ)-1 {
    zSyndrome += [initZ[i] != currZ[i]];
    if zSyndrome[i] {
      Message("Found Z error at " + DoubleAsStringWithPrecision(IntAsDouble(i), 1))
    }
  }
  return (xSyndrome, zSyndrome);
}

operation RotatedSurfaceCode(d: Int, r: Int): Result[] {
  let TOTAL_DATA_QUBITS = d*d;
  use qubits = Qubit[TOTAL_DATA_QUBITS];
  use ancillaX = Qubit[(TOTAL_DATA_QUBITS-1)/2];
  use ancillaZ = Qubit[(TOTAL_DATA_QUBITS-1)/2];
  
  ResetAll(qubits);
  // ApplyToEach(X, qubits);
  let (xMaps, zMaps) = GetMaps(d);
  GenerateLattice(xMaps, zMaps, qubits, ancillaX, ancillaZ);
  
  let measuresX = MeasureEachZ(ancillaX);
  let measuresZ = MeasureEachZ(ancillaZ);
  let results = MeasureEachZ(qubits);
  // printMaps(xMaps, zMaps);
  ResetAll(qubits);
  ResetAll(ancillaX);
  ResetAll(ancillaZ);
  return measuresX + measuresZ + results;
}
operation RunRotated(): Result[] {
  return RotatedSurfaceCode(3,5);
}


function printMaps(xMaps: Int[][], zMaps: Int[][]): Unit {
  // Utility to print the maps of surface code
  Message("Printing X Maps:");
  for i in 0..Length(xMaps)-1 {
    mutable str = "";
    for val in xMaps[i] {
      str += DoubleAsStringWithPrecision(IntAsDouble(val), 0) + ",";
    }
    Message(DoubleAsStringWithPrecision(IntAsDouble(i), 0)+"["+str+"]")
  }
  Message("Printing Z Maps:");
  for i in 0..Length(zMaps)-1 {
    mutable str = "";
    for val in zMaps[i] {
      str += DoubleAsStringWithPrecision(IntAsDouble(val), 0) + ",";
    }
    Message(DoubleAsStringWithPrecision(IntAsDouble(i), 0)+"["+str+"]")
  }
}




