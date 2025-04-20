import Std.ResourceEstimation.MeasurementCount;
import Std.Arrays.ForEach;
import Std.Diagnostics.ConfigurePauliNoise;

import Std.Diagnostics.DumpMachine;
import Std.Convert.IntAsDouble;
import Std.Convert.DoubleAsStringWithPrecision;
import Std.Diagnostics.DumpRegister;

function validIndex(d: Int, index:Int): Bool {
  if 0 <= index and index < d*d {
    return true;
  }
  return false;
}

operation CorrectDataQubit(qubit: Qubit, theta1: Double, theta2: Double, theta3: Double) : Unit is Adj + Ctl {
  // Applies the correction of on data qubit as unitary
    Rz(theta1, qubit);
    Ry(theta2, qubit);
    Rz(theta3, qubit);
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
operation MeasureLogicalZTopDown(d: Int, dataQubits: Qubit[]): Result {
    // Logical Z is assumed to be a product of physical Zs on a vertical line
    // Choose the first column: index i*d for i in 0..d-1
    mutable parity = Zero;
    
    for i in 0..d-1 {
        let index = i * d;
        let res = M(dataQubits[index]);
        
        if res == One {
            set parity = if (parity == Zero) { One } else { Zero };
        }
    }
    return parity;
}

operation MeasureLogicalZAntiDiagonal(d: Int, dataQubits: Qubit[]): Result {
    mutable parity = Zero;

    for i in 0..d-1 {
        let index = i * d + (d - 1 - i); // anti-diagonal index
        let res = M(dataQubits[index]);

        if res == One {
            set parity = if (parity == Zero) { One } else { Zero };
        }
    }

    return parity;
}

operation MeasureLogicalZLastRow(d: Int, dataQubits: Qubit[]): Result {
    mutable parity = Zero;
    let startIndex = (d - 1) * d;

    for i in 0..d-1 {
        let index = startIndex + i;
        let res = M(dataQubits[index]);

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


  operation GetMaps(d: Int): (Int[][], Int[][], String[]) {
    let TOTAL_DATA_QUBITS = d*d;
    mutable xMaps = [];
    mutable zMaps = [];
    mutable order = [];
    mutable isZ = true;
    for i in 0..d-2 {
    for j in 0..d-2 {
      let id = (i*d)+j;
      if (i == 0)  and (j % 2 == 0) {
        order += ["X"];
        let indexes = [id, id+1];
        xMaps += [indexes];
      }
      if (i%2 == 1)  and (j == 0) {
        order += ["Z"];
        let indexes = [id, id+d];
        zMaps += [indexes];
      }

      let indexes = [id, id+1, id+d, id+d+1];
      if (isZ) {
        order += ["Z"];
        zMaps += [indexes];
      } else {
        order += ["X"];
        xMaps += [indexes];
      }
      
      if j != d-2 {
        set isZ = not isZ;
      }


      if (j == d-2)  and (i % 2 == 0) {
        order += ["Z"];
        let indexes = [id+1, id+d+1];
        zMaps += [indexes];
      }
    }
  }
  for j in 0..d-2 {
    if (j % 2 == 1) {
        order += ["X"];
        let id = ((d-1)*d)+j;
        let indexes = [id, id+1];
        xMaps += [indexes];
      }
  }
  return (xMaps, zMaps, order);
  }

operation GenerateLattice(xMaps: Int[][], zMaps: Int[][], qubits: Qubit[], ancillaX: Qubit[], ancillaZ: Qubit[], order: String[]): Unit {
  mutable xi = 0;
  mutable zi = 0;
  for o in order {
    if o == "X" {
      XStabilizer(xMaps[xi], qubits, ancillaX[xi]);
      xi += 1;
    } else {
      ZStabilizer(zMaps[zi], qubits, ancillaZ[zi]);
      
      zi += 1;
    }
    
  }

}

operation Detector(initX: Result[], currX:Result[], initZ: Result[], currZ: Result[]): (Result[], Result[]) {
  mutable xSyndrome = [];
  mutable zSyndrome = [];
  for i in 0..Length(initX)-1 {
    xSyndrome += [initX[i] != currX[i] ? One | Zero];
  }
  for i in 0..Length(initZ)-1 {
    zSyndrome += [initZ[i] != currZ[i] ? One | Zero];
  }
  return (xSyndrome, zSyndrome);
}


operation Round(TOTAL_DATA_QUBITS: Int, qubits: Qubit[], xMaps:Int[][], zMaps: Int[][], order: String[]): (Result[], Result[]) {
  use ancillaX = Qubit[(TOTAL_DATA_QUBITS-1)/2];
  use ancillaZ = Qubit[(TOTAL_DATA_QUBITS-1)/2];
  GenerateLattice(xMaps, zMaps, qubits, ancillaX, ancillaZ, order);
  let measuresZ = MeasureEachZ(ancillaZ);
  let measuresX = MeasureEachZ(ancillaX);
  ResetAll(ancillaX);
  ResetAll(ancillaZ);
  return (measuresX, measuresZ);
}


operation RotatedSurfaceCode(d: Int, r: Int): Result[] {
  let TOTAL_DATA_QUBITS = d*d;
  use qubits = Qubit[TOTAL_DATA_QUBITS];
  // ConfigurePauliNoise(0.1, 0.0, 0.0);
  
  ResetAll(qubits);

  let (xMaps, zMaps, order) = GetMaps(d);
  
  let (syndromeX1, syndromeZ1) = Round(TOTAL_DATA_QUBITS, qubits, xMaps, zMaps, order);
  let (syndromeX2, syndromeZ2) = Round(TOTAL_DATA_QUBITS, qubits, xMaps, zMaps, order);
  let (detectionX, detectionZ) = Detector(syndromeX1, syndromeX2, syndromeZ1, syndromeZ2);
  let results = MeasureEachZ(qubits);
  

  ResetAll(qubits);
  return detectionX + detectionZ + results;
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


function printArray(map: Int[]): Unit {
  mutable str = "";
    for val in map {
      str += DoubleAsStringWithPrecision(IntAsDouble(val), 0) + ",";
    }
    Message("["+str+"]");
}



