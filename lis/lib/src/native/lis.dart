library lis.internal.native.lis;

import "dart-ext:lis_extension";

import 'package:complex/complex.dart';

import '../lis.dart' as lis;

abstract class NativeLIS<S> implements lis.LIS<S> {
  NativeLIS(List<String> options) {
    initialize(options);
  }

  // Vector Operations
  int vectorCreate() native "LIS_VectorCreate";
  void vectorSetSize(int vec, int n) native "LIS_VectorSetSize";
  void vectorDestroy(int vec) native "LIS_VectorDestroy";
  int vectorDuplicate(int vin) native "LIS_VectorDuplicate";
  int vectorGetSize(int v) native "LIS_VectorGetSize";
  S vectorGetValue(int v, int i) native "LIS_VectorGetValue";
  List<S> vectorGetValues(int v, int start, int count)
      native "LIS_VectorGetValues";
  void vectorSetValue(int flag, int i, S value, int v)
      native "LIS_VectorSetValue";
  void vectorSetValues(
      int flag, int count, List<int> index, List<S> value, int v)
      native "LIS_VectorSetValues";
  void vectorSetValues2(int flag, int start, int count, List<S> value, int v)
      native "LIS_VectorSetValues2";
  void vectorPrint(int x) native "LIS_VectorPrint";
  int vectorIsNull(int v) native "LIS_VectorIsNull";
  void vectorSwap(int vsrc, int vdst) native "LIS_VectorSwap";
  void vectorCopy(int vsrc, int vdst) native "LIS_VectorCopy";
  void vectorAxpy(S alpha, int vx, int vy) native "LIS_VectorAxpy";
  void vectorXpay(int vx, S alpha, int vy) native "LIS_VectorXpay";
  void vectorAxpyz(S alpha, int vx, int vy, int vz) native "LIS_VectorAxpyz";
  void vectorScale(S alpha, int vx) native "LIS_VectorScale";
  void vectorPmul(int vx, int vy, int vz) native "LIS_VectorPmul";
  void vectorPdiv(int vx, int vy, int vz) native "LIS_VectorPdiv";
  void vectorSetAll(S alpha, int vx) native "LIS_VectorSetAll";
  void vectorAbs(int vx) native "LIS_VectorAbs";
  void vectorReciprocal(int vx) native "LIS_VectorReciprocal";
  void vectorShift(S alpha, int vx) native "LIS_VectorShift";
  S vectorDot(int vx, int vy) native "LIS_VectorDot";
  double vectorNrm1(int vx) native "LIS_VectorNrm1";
  double vectorNrm2(int vx) native "LIS_VectorNrm2";
  double vectorNrmi(int vx) native "LIS_VectorNrmi";
  S vectorSum(int vx) native "LIS_VectorSum";
  void vectorReal(int vx) native "LIS_VectorReal";
  void vectorImaginary(int vx) native "LIS_VectorImaginary";
  void vectorArgument(int vx) native "LIS_VectorArgument";
  void vectorConjugate(int vx) native "LIS_VectorConjugate";

  // Matrix Operations
  int matrixCreate() native "LIS_MatrixCreate";
  void matrixDestroy(int Amat) native "LIS_MatrixDestroy";
  void matrixAssemble(int A) native "LIS_MatrixAssemble";
  int matrixIsAssembled(int A) native "LIS_MatrixIsAssembled";
  int matrixDuplicate(int Ain) native "LIS_MatrixDuplicate";
  void matrixSetSize(int A, int n) native "LIS_MatrixSetSize";
  int matrixGetSize(int A) native "LIS_MatrixGetSize";
  int matrixGetNnz(int A) native "LIS_MatrixGetNnz";
  void matrixSetType(int A, int matrix_type) native "LIS_MatrixSetType";
  int matrixGetType(int A) native "LIS_MatrixGetType";
  void matrixSetValue(int flag, int i, int j, S value, int A)
      native "LIS_MatrixSetValue";
  void matrixSetValues(int flag, int n, List<S> value, int A)
      native "LIS_MatrixSetValues";
  void matrixMalloc(int A, int nnz_row, List<int> nnz)
      native "LIS_MatrixMalloc";
  int matrixGetDiagonal(int A) native "LIS_MatrixGetDiagonal";
  void matrixConvert(int Ain, int Aout) native "LIS_MatrixConvert";
  void matrixCopy(int Ain, int Aout) native "LIS_MatrixCopy";
  void matrixTranspose(int Ain, int Aout) native "LIS_MatrixTranspose";

  void matrixSetCsr(
      int nnz, List<int> row, List<int> index, List<S> value, int A)
      native "LIS_MatrixSetCsr";
  void matrixSetCsc(
      int nnz, List<int> row, List<int> index, List<S> value, int A)
      native "LIS_MatrixSetCsc";
  void matrixSetBsr(int bnr, int bnc, int bnnz, List<int> bptr,
      List<int> bindex, List<S> value, int A) native "LIS_MatrixSetBsr";
  void matrixSetMsr(int nnz, int ndz, List<int> index, List<S> value, int A)
      native "LIS_MatrixSetMsr";
  void matrixSetEll(int maxnzr, List<int> index, List<S> value, int A)
      native "LIS_MatrixSetEll";
  void matrixSetJad(int nnz, int maxnzr, List<int> perm, List<int> ptr,
      List<int> index, List<S> value, int A) native "LIS_MatrixSetJad";
  void matrixSetDia(int nnd, List<int> index, List<S> value, int A)
      native "LIS_MatrixSetDia";
  void matrixSetBsc(int bnr, int bnc, int bnnz, List<int> bptr,
      List<int> bindex, List<S> value, int A) native "LIS_MatrixSetBsc";
  void matrixSetVbr(
      int nnz,
      int nr,
      int nc,
      int bnnz,
      List<int> row,
      List<int> col,
      List<int> ptr,
      List<int> bptr,
      List<int> bindex,
      List<S> value,
      int A) native "LIS_MatrixSetVbr";
  void matrixSetCoo(int nnz, List<int> row, List<int> col, List<S> value, int A)
      native "LIS_MatrixSetCoo";
  void matrixSetDns(List<S> value, int A) native "LIS_MatrixSetDns";

  // Matrix-Vector Operations
  void matvec(int A, int x, int y) native "LIS_MatVec";
  void matvect(int A, int x, int y) native "LIS_MatVecT";

  // Linear Solvers
  int solverCreate() native "LIS_SolverCreate";
  void solverDestroy(int solver) native "LIS_SolverDestroy";
  int solverGetIter(int solver) native "LIS_SolverGetIter";
  int solverGetIterEx(int solver) native "LIS_SolverGetIterEx";
  double solverGetTime(int solver) native "LIS_SolverGetTime";
  int solverGetTimeEx(int solver) native "LIS_SolverGetTimeEx";
  double solverGetResidualNorm(int solver) native "LIS_SolverGetResidualNorm";
  int solverGetSolver(int solver) native "LIS_SolverGetSolver";
  int solverGetPrecon(int solver) native "LIS_SolverGetPrecon";
  int solverGetStatus(int solver) native "LIS_SolverGetStatus";
  void solverGetRHistory(int solver, int v) native "LIS_SolverGetRHistory";
  void solverSetOption(String text, int solver) native "LIS_SolverSetOption";
  void solverSetOptionC(int solver) native "LIS_SolverSetOptionC";
  void solve(int A, int b, int x, int solver) native "LIS_Solve";

  // Eigensolvers
  int esolverCreate() native "LIS_EsolverCreate";
  int esolverDestroy(int esolver) native "LIS_EsolverDestroy";
  int iesolverDestroy(int esolver) native "iesolverDestroy";
  int esolverSetOption(String text, int esolver) native "LIS_EsolverSetOption";
  int esolverSetOptionC(int esolver) native "LIS_EsolverSetOptionC";
  S esolve(int A, int x, int esolver) native "LIS_Esolve";
  int esolverGetIter(int esolver) native "LIS_EsolverGetIter";
  int esolverGetIterEx(int esolver) native "LIS_EsolverGetIterEx";
  double esolverGetTime(int esolver) native "LIS_EsolverGetTime";
  int esolverGetTimeEx(int esolver) native "LIS_EsolverGetTimeEx";
  double esolverGetResidualNorm(int esolver)
      native "LIS_EsolverGetResidualNorm";
  int esolverGetStatus(int esolver) native "LIS_EsolverGetStatus";
  void esolverGetRHistory(int esolver, int v) native "LIS_EsolverGetRHistory";
  void esolverGetEvalues(int esolver, int v) native "LIS_EsolverGetEvalues";
  void esolverGetEvectors(int esolver, int M) native "LIS_EsolverGetEvectors";
  void esolverGetResidualNorms(int esolver, int v)
      native "LIS_EsolverGetResidualNorms";
  void esolverGetIters(int esolver, int v) native "LIS_EsolverGetIters";
  int esolverGetEsolver(int esolver) native "LIS_EsolverGetEsolver";

  // I/O Functions
  void input(int A, int b, int x, String s) native "LIS_Input";
  void inputMatrix(int A, String s) native "LIS_InputMatrix";
  void inputVector(int v, String s) native "LIS_InputVector";
  String output(int A, int b, int x, int mode, [String path])
      native "LIS_Output";
  String outputMatrix(int A, int mode, [String path]) native "LIS_OutputMatrix";
  String outputVector(int v, int format, [String filename])
      native "LIS_OutputVector";
  String solverOutputRHistory(int solver, [String filename])
      native "LIS_SolverOutputRHistory";
  String esolverOutputRHistory(int esolver, [String filename])
      native "LIS_EsolverOutputRHistory";

  // Utilities
  void initialize(List<String> args) native "LIS_Initialize";
  int finalize() native "LIS_Finalize";
  void CHKERR(int err) native "LIS_CHKERR";
}

class DLIS extends NativeLIS<double> {
  DLIS([List<String> options]) : super(options);
  double get one => 1.0;
  double get zero => 0.0;
}

class ZLIS extends NativeLIS<Complex> {
  ZLIS([List<String> options]) : super(options);
  Complex get one => Complex.ONE;
  Complex get zero => Complex.ZERO;
}
