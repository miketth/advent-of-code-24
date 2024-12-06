package industries.disappointment;

import java.util.LinkedList;
import java.util.List;

public interface Field extends Cloneable {
    void meetGuard(Guard guard);
    List<Direction> previousGuardDirections();
    public Field clone();

    class Obstruction implements Field {
        @Override
        public void meetGuard(Guard guard) {
            guard.direction = guard.direction.next();
        }

        @Override
        public List<Direction> previousGuardDirections() {
            return List.of();
        }

        @Override
        public Obstruction clone() {
            try {
                return (Obstruction) super.clone();
            } catch (CloneNotSupportedException e) {
                return new Obstruction();
            }
        }
    }

    class Empty implements Field {
        List<Direction> guardDirections = new LinkedList<>();

        @Override
        public void meetGuard(Guard guard) {
            guardDirections.add(guard.direction);
            guard.position = guard.nextPosition();
        }

        @Override
        public List<Direction> previousGuardDirections() {
            return guardDirections;
        }

        public Empty(Direction guardDirectionOnIt) {
            if (guardDirectionOnIt != null) {
                guardDirections.add(guardDirectionOnIt);
            }
        }

        public Empty() {}

        @Override
        public Empty clone() {
            Empty empty;
            try {
                empty = (Empty) super.clone();
            } catch (CloneNotSupportedException e) {
                empty = new Empty();
            }
            empty.guardDirections = new LinkedList<>(guardDirections);
            return empty;
        }
    }
}
