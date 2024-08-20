class Prize {
  final String name;
  final int percentage; // Changed to int

  Prize({required this.name, required this.percentage});

  // Default or empty prize
  static Prize empty() {
    return Prize(name: '', percentage: 0);
  }

  // Convert a Prize to a String for storage
  @override
  String toString() => '$name,$percentage';

  // Parse a Prize from a String
  factory Prize.fromString(String prizeString) {
    final parts = prizeString.trim().split(',');
    if (parts.length != 2) {
      throw FormatException('Invalid prize format');
    }
    final name = parts[0].trim();
    final percentage = int.tryParse(parts[1].trim()) ?? 0; // Changed to int
    return Prize(name: name, percentage: percentage);
  }
}
