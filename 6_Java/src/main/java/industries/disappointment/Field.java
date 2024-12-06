package industries.disappointment;

import java.util.LinkedList;
import java.util.List;

public interface Field {
    void meetGuard(Guard guard);
    List<Direction> previousGuardDirections();

    class Obstruction implements Field {
        @Override
        public void meetGuard(Guard guard) {
            guard.direction = guard.direction.next();
        }

        @Override
        public List<Direction> previousGuardDirections() {
            return List.of();
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
    }
}
