package industries.disappointment

enum Operation {
    AND, OR, XOR

    static Operation toOperation(final String s) {
        switch (s) {
            case "AND": return AND
            case "OR": return OR
            case "XOR": return XOR
        }

        throw new Exception("no such operation: ${s}")
    }

    Integer doOp(Integer a, b) {
        switch (this) {
            case AND: return a & b
            case OR: return a | b
            case XOR: return a ^ b
        }

        throw new Exception("no such operation: ${this}")
    }
}

