package industries.disappointment

record ParsedFile(
    HashMap<String, Integer> solved,
    HashMap<String, CalculatedWire> remaining
) {}
