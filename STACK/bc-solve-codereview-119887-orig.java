package net.coderodde.util;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

public class CombinationIterable<T> implements Iterable<List<T>> {

    private final List<T> allElements;

    public CombinationIterable(List<T> allElements) {
        this.allElements = new ArrayList<>(allElements);
    }

    @Override
	public Iterator<List<T>> iterator() {
        return new CombinationIterator<>(allElements);
    }

    private static final class CombinationIterator<T> 
	implements Iterator<List<T>> {

        private final List<T> allElements;
        private final int[] indices;
        private List<T> nextCombination;
        private int currentCombinationSize;

        CombinationIterator(List<T> allElements) {
            this.allElements = new ArrayList<>(allElements);
            this.indices = new int[allElements.size()];

            if (!allElements.isEmpty()) {
                // Create the first combination.
                currentCombinationSize = 1;
                nextCombination = new ArrayList<>(1);
                nextCombination.add(allElements.get(0));
            }
        }

        @Override
	    public boolean hasNext() {
            return nextCombination != null;
        }

        @Override
	    public List<T> next() {
            if (nextCombination == null) {
                throw new NoSuchElementException("No combinations left.");
            }

            List<T> combination = nextCombination;
            generateNextCombination();
            return combination;
        }

        private void loadCombination() {
            List<T> combination = new ArrayList<>(currentCombinationSize);

            for (int i = 0; i < currentCombinationSize; ++i) {
                combination.add(allElements.get(indices[i]));
            }

            this.nextCombination = combination;
        }

        private void generateNextCombination() {
            if (indices[currentCombinationSize - 1] < indices.length - 1) {
                indices[currentCombinationSize - 1]++;
                loadCombination();
                return;
            }

            for (int i = currentCombinationSize - 2; i >= 0; --i) {
                if (indices[i] < indices[i + 1] - 1) {
                    indices[i]++;

                    for (int j = i + 1; j < currentCombinationSize; ++j) {
                        indices[j] = indices[j - 1] + 1;
                    }

                    loadCombination();
                    return;
                }
            }

            ++currentCombinationSize;

            if (currentCombinationSize > indices.length) {
                this.nextCombination = null;
                return;
            }

            for (int i = 0; i < currentCombinationSize; ++i) {
                indices[i] = i;
            }

            loadCombination();
        }
    }

    public static void main(String[] args) {
        List<String> all = new ArrayList<>();

        all.add("A");
        all.add("B");
        all.add("C");
        all.add("D");
        all.add("E");

        int row = 1;

        for (List<String> combination : new CombinationIterable<>(all)) {
            System.out.printf("%2d: %s\n", row++, combination);
        }
    }
}

CombinationIterableTest.java:

    package net.coderodde.util;

import java.util.ArrayList;
import java.util.List;
import org.junit.Test;
import static org.junit.Assert.*;

public class CombinationIterableTest {

    private CombinationIterable generator;

    @Test
	public void test() {
        List<String> all = new ArrayList<>();

        all.add("A");
        all.add("B");
        all.add("C");
        all.add("D");
        all.add("E");

        for (int i = 1; i <= all.size(); ++i) {
            List<String> list = new ArrayList<>();

            for (int j = 0; j < i; ++j) {
                list.add(all.get(j));
            }

            int combinations = pow2(i) - 1;
            int count = 0;

            for (List<String> combination : new CombinationIterable<>(list)) {
                ++count;
            }

            assertEquals(combinations, count);
        }
    }

    private static int pow2(int exp) {
        return 1 << exp;
    }
}
