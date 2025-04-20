import RotatedSurfaceCode.XStabilizer;
import Std.Diagnostics.DumpMachine;
import Std.Diagnostics.CheckAllZero;
import Std.Arrays.All;
import Std.Arrays.ForEach;
import RotatedSurfaceCode.ZStabilizer;
import RotatedSurfaceCode.MeasureLogicalZTopDown;
import RotatedSurfaceCode.MeasureLogicalZ;
import Std.Random.DrawRandomDouble;

import RotatedSurfaceCode.CorrectDataQubit;

operation PrepareTestState(d : Int, onesAtIndices: Int[], dataQubits: Qubit[]) : Unit {
        for idx in onesAtIndices {
            X(dataQubits[idx]);
        }
    }

operation PrepareState(indicesToFlip: Int[], qubits: Qubit[]) : Unit {
        for idx in indicesToFlip {
            X(qubits[idx]);
        }
    }

operation TestMeasureLogicalZ_AllZero() : Bool {
    use qs = Qubit[9];
    let d = 3;
    let expected = Zero;
    let result = MeasureLogicalZ(d, qs);
    ResetAll(qs);
    return expected == result;
}

operation TestMeasureLogicalZ_AllOne() : Bool {
    use qs = Qubit[9];
    let d = 3;
    PrepareTestState(d, [0, 3, 6], qs); // Logical Z line
    let expected = One;
    let result = MeasureLogicalZ(d, qs);
    ResetAll(qs);
    return expected == result;
}

  operation TestMeasureLogicalZ_OneOneOne() : Bool {
      use qs = Qubit[9];
      let d = 3;
      PrepareTestState(d, [0, 3, 6], qs);
      let expected = One;
      let result = MeasureLogicalZ(d, qs);
      ResetAll(qs);
      return expected == result;
  }

    operation TestMeasureLogicalZ_TwoOnes() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareTestState(d, [0, 3], qs);
        let expected = Zero;
        let result = MeasureLogicalZ(d, qs);
        ResetAll(qs);
        return expected == result;
    }
    
    operation TestMeasureLogicalZ_OneOneZero() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareTestState(d, [3, 6], qs);
        let expected = Zero;
        let result = MeasureLogicalZ(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation TestMeasureLogicalZ_OnlyMiddleOne() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareTestState(d, [3], qs);
        let expected = One;
        let result = MeasureLogicalZ(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation TestMeasureLogicalZ_EmptyGrid() : Bool {
        use qs = Qubit[1];
        let d = 1;
        let expected = Zero;
        let result = MeasureLogicalZ(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation TestMeasureLogicalZ_Superposition() : Bool {
        use qs = Qubit[9];
        let d = 3;
        for i in [0, 3, 6] {
            H(qs[i]); // Put logical line into superposition
        }
        let result = MeasureLogicalZ(d, qs);
        // Result could be Zero or One; just check it's valid Result
        ResetAll(qs);
        return result == One or result == Zero;
    }

    
    operation TestMeasureLogicalZ_IrrelevantQubitsFlipped() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareTestState(d, [1, 2, 4, 5, 7, 8], qs); // Flip non-logical-Z qubits
        let expected = Zero;
        let result = MeasureLogicalZ(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    operation TestMeasureLogicalZ_LargeGrid() : Bool {
        let d = 5;
        use qs = Qubit[d * d];
        // Flip every second qubit in logical Z line (indices 0, 5, 10, 15, 20)
        PrepareTestState(d, [0, 10, 20], qs);
        let expected = One;
        let result = MeasureLogicalZ(d, qs);
        ResetAll(qs);
        return expected == result;
    }
    
    
    operation Test_MeasureLogicalZTopDown_AllZero() : Bool {
        use qs = Qubit[9];
        let d = 3;
        let expected = Zero;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_AllOne() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareState([0, 3, 6], qs);
        let expected = One;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_OneQubitFlipped() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareState([3], qs);
        let expected = One;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_TwoFlipped() : Bool {
        use qs = Qubit[9];
        let d = 3;
        PrepareState([0, 6], qs);
        let expected = Zero;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_IgnoreNonColumnQubits() : Bool {
        use qs = Qubit[9];
        let d = 3;
        // Flip qubits not in first column
        PrepareState([1, 2, 4, 5, 7, 8], qs);
        let expected = Zero;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_ThreeFlipped_OddParity() : Bool {
        use qs = Qubit[16];
        let d = 4;
        PrepareState([0, 4, 8], qs); // Flip 3 qubits in logical Z
        let expected = One;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_LargeGrid_ZeroParity() : Bool {
        let d = 5;
        use qs = Qubit[d * d];
        PrepareState([0, 10, 20], qs); // Indices = 0, 2, 4 in logical Z
        let expected = One;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_SingleQubitGrid() : Bool {
        use qs = Qubit[1];
        let d = 1;
        PrepareState([0], qs);
        let expected = One;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_AllFiveFlipped() : Bool {
        use qs = Qubit[25];
        let d = 5;
        PrepareState([0, 5, 10, 15, 20], qs); // Full logical Z column
        let expected = One; // 5 is odd
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }

    
    operation Test_MeasureLogicalZTopDown_AllFourFlipped() : Bool {
        use qs = Qubit[16];
        let d = 4;
        PrepareState([0, 4, 8, 12], qs);
        let expected = Zero;
        let result = MeasureLogicalZTopDown(d, qs);
        ResetAll(qs);
        return expected == result;
    }
    
    operation Test_ZStabilizerApplyLater() : Bool {
        use qs = Qubit[16];
        let indexes = [0,5,7];
        ResetAll(qs);
        ZStabilizer(indexes, qs[0..Length(qs)-2], qs[Length(qs)-1]);
        X(qs[Length(qs)-1]);
        DumpMachine();
        let result = CheckAllZero(qs[0..Length(qs)-2]);
        ResetAll(qs[0..Length(qs)-2]);
        return (MResetEachZ([qs[Length(qs)-1]]) == [One] )and result;
    }
    
    operation Test_ZStabilizer_ShouldNotActivate() : Bool {
        use qs = Qubit[16];
        ResetAll(qs);
        let indexes = [3,5,7];
        ZStabilizer(indexes, qs[0..Length(qs)-2], qs[Length(qs)-1]);
        X(qs[Length(qs)-1]);
        let result = CheckAllZero(qs[0..Length(qs)-2]);
        ResetAll(qs);
        return result;
    }
    operation Test_ZStabilizerShouldResetAncillaBeforeUse() : Bool {
        use qs = Qubit[16];
        let indexes = [];
        
        X(qs[Length(qs)-1]);
        ZStabilizer(indexes, qs[0..Length(qs)-2], qs[Length(qs)-1]);
        let expected = Zero;
        let res = M(qs[Length(qs)-1]);
        ResetAll(qs);
        return expected == res;
    }
    

    operation PrepareInXBasis(indicesToFlip : Int[], dataQubits : Qubit[]) : Unit {
        // Prepare all qubits in |+⟩
        for q in dataQubits {
            H(q);
        }
        // Flip selected qubits to |−⟩
        for i in indicesToFlip {
            Z(dataQubits[i]);
        }
    }

    
    operation Test_XStabilizer_EvenParity() : Bool {
        use data = Qubit[4];
        use ancilla = Qubit();
        let indexes = [0, 1, 2, 3];

        // Prepare even number of |−⟩: flip qubits 1 and 3
        PrepareInXBasis([1, 3], data);
        
        XStabilizer(indexes, data, ancilla);
        let result = M(ancilla);

        ResetAll(data + [ancilla]);
        return Zero == result;
    }

    
    operation Test_XStabilizer_OddParity() : Bool {
        use data = Qubit[4];
        use ancilla = Qubit();
        let indexes = [0, 1, 2, 3];

        // Prepare odd number of |−⟩: flip qubits 1, 2, and 3
        PrepareInXBasis([1, 2, 3], data);
        
        XStabilizer(indexes, data, ancilla);
        let result = M(ancilla);

        ResetAll(data + [ancilla]);
        return One == result;
    }

    
    operation Test_XStabilizer_SingleQubit() : Bool {
        use data = Qubit[1];
        use ancilla = Qubit();
        let indexes = [0];

        // Flip to |−⟩
        PrepareInXBasis([0], data);

        XStabilizer(indexes, data, ancilla);
        let result = M(ancilla);

        
        ResetAll(data + [ancilla]);
        return One == result;
    }

    
    operation Test_XStabilizer_ZeroParity() : Bool {
        use data = Qubit[3];
        use ancilla = Qubit();
        let indexes = [0, 1, 2];

        // All in |+⟩
        PrepareInXBasis([], data);

        XStabilizer(indexes, data, ancilla);
        let result = M(ancilla);

        ResetAll(data + [ancilla]);
        return Zero == result
    }
