namespace RotatedSurfaceCode {
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
  operation XStabilizer(d: Int, indexes: Int[], dataQubits: Qubit[]): Result {
    use q=  Qubit();
    H(q);
    for index in indexes {
      if (validIndex(d, index)) {
        CX(q, dataQubits[index]);
      }
    }
    H(q);
    let result = Measure([PauliZ], [q]);
    Reset(q);
    return result;
  }
  operation ZStabilizer(d: Int, indexes: Int[], dataQubits: Qubit[]): Result {
    use q=  Qubit();
    for index in indexes {
      if (validIndex(d, index)) {
        CX( dataQubits[index], q);
      }
    }
    let result = Measure([PauliZ], [q]);
    Reset(q);
    return result;
  }

operation GenerateLattice(d: Int, qubits: Qubit[]): (Int[][], Result[], Int[][], Result[]) {
  let TOTAL_DATA_QUBITS = d*d;
  mutable xMeasures = [];
  mutable xMaps = [];
  mutable zMaps = [];
  mutable zMeasures = [];
  mutable isZ = true;

  for i in 0..d-2 {
    for j in 0..d-2 {
      let id = (i*d)+j;
      if (i == 0)  and (j % 2 == 0) {
        let indexes = [id, id+1];
        xMeasures += [XStabilizer(d, indexes, qubits)];
        xMaps += [indexes];
      }
      if (i%2 == 1)  and (j == 0) {
        let indexes = [id, id+d];
        zMeasures += [ZStabilizer(d, indexes, qubits)];
        zMaps += [indexes];
      }

      let indexes = [id, id+1, id+d, id+d+1];
      if (isZ) {
        zMeasures += [ZStabilizer(d, indexes, qubits)];
        zMaps += [indexes];
      } else {
        xMeasures += [XStabilizer(d, indexes, qubits)];
        xMaps += [indexes];
      }
      
      if j != d-2 {
        set isZ = not isZ;
      }


      if (j == d-2)  and (i % 2 == 0) {
        let indexes = [id+1, id+d+1];
        zMeasures += [ZStabilizer(d, indexes , qubits)];
        zMaps += [indexes];
      }
      if (i == d-2)  and (j % 2 == 1) {
        let indexes = [id+d, id+d+1];
        xMeasures += [XStabilizer(d, indexes, qubits)];
        xMaps += [indexes];
      }
    }
  }
  return (xMaps, xMeasures, zMaps, zMeasures);
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

operation RotatedSurfaceCode(d: Int, r: Int): Unit {
  let TOTAL_DATA_QUBITS = d*d;
  use qubits = Qubit[TOTAL_DATA_QUBITS];
  mutable (xMaps, initXMeasures, zMaps, initZMeasures) = GenerateLattice(d, qubits);
  
  for i in 0..r-1 {
    let (x , xMeasures, z, zMeasures)  = GenerateLattice(d, qubits);
    let (xSyndrome, zSyndrome) = GetSyndroem(initXMeasures, xMeasures, initZMeasures, zMeasures);
    set initXMeasures = xMeasures;
    set initZMeasures = zMeasures;
  }
  
  ResetAll(qubits);
}
operation RunRotated(): Unit {
  RotatedSurfaceCode(5,5);
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
}



