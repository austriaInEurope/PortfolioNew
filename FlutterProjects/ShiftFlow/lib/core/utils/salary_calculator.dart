class SalaryCalculator {
  static double calculateSalary({
    required double rate,
    required double dayHours,
    required double nightHours,
  }) {
    return rate * dayHours + rate * nightHours * 1.25;
  }
}
