import qsharp
import pytest

def test_2() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_AllZero()")
    assert correct

def test_3() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_AllOne()")
    assert correct

def test_4() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_OneOneOne()")
    assert correct

def test_5() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_TwoOnes()")
    assert correct

def test_6() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_OneOneZero()")
    assert correct
def test_7() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_OnlyMiddleOne()")
    assert correct
def test_8() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_EmptyGrid()")
    assert correct
def test_9() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.TestMeasureLogicalZ_Superposition()")
    assert correct
def test_10() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_MeasureLogicalZTopDown_AllFourFlipped()")
    assert correct
def test_11() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_MeasureLogicalZTopDown_AllFiveFlipped()")
    assert correct
def test_12() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_MeasureLogicalZTopDown_SingleQubitGrid()")
    assert correct
def test_12() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_MeasureLogicalZTopDown_LargeGrid_ZeroParity()")
    assert correct
def test_13() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_MeasureLogicalZTopDown_ThreeFlipped_OddParity()")
    assert correct
def test_14() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_MeasureLogicalZTopDown_IgnoreNonColumnQubits()")
    assert correct
def test_15() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_ZStabilizerApplyLater()")
    assert correct
def test_16() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_ZStabilizer_ShouldNotActivate()")
    assert correct
def test_17() -> None:
    qsharp.init(project_root=".")
    correct = qsharp.eval("Test.Test_ZStabilizerShouldResetAncillaBeforeUse()")
    assert correct

@pytest.mark.parametrize("functionName", [
    "Test_XStabilizer_EvenParity",
    "Test_XStabilizer_OddParity",
    "Test_XStabilizer_SingleQubit",
    "Test_XStabilizer_ZeroParity"
])
def test_runner(functionName):
    print(functionName)
    qsharp.init(project_root=".")
    correct = qsharp.eval(f"Test.{functionName}()")
    assert correct


