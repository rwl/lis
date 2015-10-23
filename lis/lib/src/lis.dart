library lis.internal;

part 'vector.dart';
part 'matrix.dart';
part 'solver.dart';
part 'esolver.dart';

enum Flag { INSERT, ADD }

const int COMM_WORLD = 0x1;

enum Format { AUTO, PLAIN, MM, ASCII, BINARY, FREE, ITBL, HB, MMB }

abstract class LIS<S> {
  S get one;
  S get zero;

  // Vector Operations
  int vectorCreate();
  void vectorSetSize(int vec, int n);
  void vectorDestroy(int vec);
  int vectorDuplicate(int vin);
  int vectorGetSize(int v);
  S vectorGetValue(int v, int i);
  List<S> vectorGetValues(int v, int start, int count);
  void vectorSetValue(int flag, int i, S value, int v);
  void vectorSetValues(
      int flag, int count, List<int> index, List<S> value, int v);
  void vectorSetValues2(int flag, int start, int count, List<S> value, int v);
  void vectorPrint(int x);
  int vectorIsNull(int v);
  void vectorSwap(int vsrc, int vdst);
  void vectorCopy(int vsrc, int vdst);
  void vectorAxpy(S alpha, int vx, int vy);
  void vectorXpay(int vx, S alpha, int vy);
  void vectorAxpyz(S alpha, int vx, int vy, int vz);
  void vectorScale(S alpha, int vx);
  void vectorPmul(int vx, int vy, int vz);
  void vectorPdiv(int vx, int vy, int vz);
  void vectorSetAll(S alpha, int vx);
  void vectorAbs(int vx);
  void vectorReciprocal(int vx);
  void vectorShift(S alpha, int vx);
  S vectorDot(int vx, int vy);
  double vectorNrm1(int vx);
  double vectorNrm2(int vx);
  double vectorNrmi(int vx);
  S vectorSum(int vx);
  void vectorReal(int vx);
  void vectorImaginary(int vx);
  void vectorArgument(int vx);
  void vectorConjugate(int vx);

  // Matrix Operations
  int matrixCreate();
  void matrixDestroy(int Amat);
  void matrixAssemble(int A);
  int matrixIsAssembled(int A);
  int matrixDuplicate(int Ain);
  void matrixSetSize(int A, int n);
  int matrixGetSize(int A);
  int matrixGetNnz(int A);
  void matrixSetType(int A, int matrix_type);
  int matrixGetType(int A);
  void matrixSetValue(int flag, int i, int j, S value, int A);
  void matrixSetValues(int flag, int n, List<S> value, int A);
  void matrixMalloc(int A, int nnz_row, List<int> nnz);
  void matrixGetDiagonal(int A, int d);
  void matrixConvert(int Ain, int Aout);
  void matrixCopy(int Ain, int Aout);
  void matrixTranspose(int Ain, int Aout);

  void matrixSetCsr(
      int nnz, List<int> row, List<int> index, List<S> value, int A);
  void matrixSetCsc(
      int nnz, List<int> row, List<int> index, List<S> value, int A);
  void matrixSetBsr(int bnr, int bnc, int bnnz, List<int> bptr,
      List<int> bindex, List<S> value, int A);
  void matrixSetMsr(int nnz, int ndz, List<int> index, List<S> value, int A);
  void matrixSetEll(int maxnzr, List<int> index, List<S> value, int A);
  void matrixSetJad(int nnz, int maxnzr, List<int> perm, List<int> ptr,
      List<int> index, List<S> value, int A);
  void matrixSetDia(int nnd, List<int> index, List<S> value, int A);
  void matrixSetBsc(int bnr, int bnc, int bnnz, List<int> bptr,
      List<int> bindex, List<S> value, int A);
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
      int A);
  void matrixSetCoo(
      int nnz, List<int> row, List<int> col, List<S> value, int A);
  void matrixSetDns(List<S> value, int A);

  // Matrix-Vector Operations
  void matvec(int A, int x, int y);
  void matvect(int A, int x, int y);

  // Linear Solvers
  int solverCreate();
  void solverDestroy(int solver);
  int solverGetIter(int solver);
  Iter solverGetIterEx(int solver);
  double solverGetTime(int solver);
  Time solverGetTimeEx(int solver);
  double solverGetResidualNorm(int solver);
  int solverGetSolver(int solver);
  int solverGetPrecon(int solver);
  int solverGetStatus(int solver);
  void solverGetRHistory(int solver, int v);
  void solverSetOption(String text, int solver);
  void solverSetOptionC(int solver);
  void solve(int A, int b, int x, int solver);

  // Eigensolvers
  int esolverCreate();
  void esolverDestroy(int esolver);
  void esolverSetOption(String text, int esolver);
  void esolverSetOptionC(int esolver);
  S esolve(int A, int x, int esolver);
  int esolverGetIter(int esolver);
  Iter esolverGetIterEx(int esolver);
  double esolverGetTime(int esolver);
  Time esolverGetTimeEx(int esolver);
  double esolverGetResidualNorm(int esolver);
  int esolverGetStatus(int esolver);
  void esolverGetRHistory(int esolver, int v);
  void esolverGetEvalues(int esolver, int v);
  void esolverGetEvectors(int esolver, int M);
  void esolverGetResidualNorms(int esolver, int v);
  void esolverGetIters(int esolver, int v);
  int esolverGetEsolver(int esolver);

  // I/O Functions
  void input(int A, int b, int x, String s);
  void inputMatrix(int A, String s);
  void inputVector(int v, String s);
  String output(int A, int b, int x, int mode);
  String outputMatrix(int A, int mode);
  String outputVector(int v, int format);
  String solverOutputRHistory(int solver);
  String esolverOutputRHistory(int esolver);

  /*void read(int A, int b, int x, String filename);
  void readMatrix(int A, String filename);
  void readVector(int v, String filename);
  void write(int A, int b, int x, int mode, String path);
  void writeMatrix(int A, int mode, String path);
  void writeVector(int v, int format, String filename);
  void solverWriteRHistory(int solver, String filename);
  void esolverWriteRHistory(int esolver, String filename);*/

  // Utilities
  void initialize(List<String> args);
  void finalize();
  void CHKERR(int err);
}

class LinearProblem<S> {
  final LIS _lis;
  final Matrix<S> A;
  final Vector<S> b, x;

  factory LinearProblem(LIS lis, String data) {
    var A = new Matrix<S>(lis);
    var b = new Vector<S>(lis);
    var x = new Vector<S>(lis);
    lis.input(A._p_mat, b._p_vec, x._p_vec, data);
    return new LinearProblem<S>._(lis, A, b, x);
  }

  LinearProblem._(this._lis, this.A, this.b, this.x);

  String output() => _lis.output(A._p_mat, b._p_vec, x._p_vec, Format.MM.index);
}
