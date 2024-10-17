import unittest
from typing import List
import numpy as np
from matplotlib import pyplot as plt


# Function to plot ranges
def visualise_intersections(A: List[List[int]], B: List[List[int]]) -> None:
    _, ax = plt.subplots(figsize=(8, 2))

    # Plot ranges for A
    for i, (start, stop) in enumerate(A):
        ax.plot([start, stop], [1, 1], color="blue", lw=6, label="A" if i == 0 else "")

    # Plot ranges for B
    for i, (start, stop) in enumerate(B):
        ax.plot([start, stop], [2, 2], color="red", lw=6, label="B" if i == 0 else "")

    # Mark overlap
    overlap_ranges = []
    for start_A, stop_A in A:
        for start_B, stop_B in B:
            overlap_start = max(start_A, start_B)
            overlap_stop = min(stop_A, stop_B)
            if overlap_start <= overlap_stop:  # There's an overlap
                overlap_ranges.append([overlap_start, overlap_stop])
                ax.plot(
                    [overlap_start, overlap_stop],
                    [1.5, 1.5],
                    color="green",
                    lw=6,
                    label="Overlap" if len(overlap_ranges) == 1 else "",
                )

    # Customize the plot
    ax.set_yticks([1, 1.5, 2])
    ax.set_yticklabels(["A", "Overlap", "B"])
    ax.set_xlabel("Number Line")
    ax.legend()
    ax.grid(True, axis="x")

    plt.show()


def interval_intersection(A: List[List[int]], B: List[List[int]]) -> np.ndarray:
    A = sorted(A, key=lambda x: x[0])
    B = sorted(B, key=lambda x: x[0])

    i, j = 0, 0
    result = []

    while i < len(A) and j < len(B):
        a_start, a_end = A[i]
        b_start, b_end = B[j]

        if a_start <= b_end and b_start <= a_end:  # Overlapping intervals
            result.append([max(a_start, b_start), min(a_end, b_end)])

        if a_end <= b_end:
            i += 1
        else:
            j += 1

    return np.array(result)


class TestIntervalIntersection(unittest.TestCase):

    def test_overlapping_intervals(self):
        A = [[1, 3], [5, 9], [12, 15]]
        B = [[2, 6], [8, 10], [14, 18]]
        result = interval_intersection(A, B)
        expected = np.array([[2, 3], [5, 6], [8, 9], [14, 15]])
        np.testing.assert_array_equal(result, expected)

    def test_non_overlapping_intervals(self):
        A = [[1, 2], [5, 7]]
        B = [[3, 4], [8, 10]]
        result = interval_intersection(A, B)
        expected = np.array([])  # No intersections
        np.testing.assert_array_equal(result, expected)

    def test_one_list_empty(self):
        A = [[1, 2], [5, 7]]
        B = []
        result = interval_intersection(A, B)
        expected = np.array([])  # No intersections since B is empty
        np.testing.assert_array_equal(result, expected)

    def test_both_lists_empty(self):
        A = []
        B = []
        result = interval_intersection(A, B)
        expected = np.array([])  # No intersections since both are empty
        np.testing.assert_array_equal(result, expected)

    def test_enclosing_intervals(self):
        A = [[1, 10]]
        B = [[2, 5], [6, 9]]
        result = interval_intersection(A, B)
        expected = np.array([[2, 5], [6, 9]])
        np.testing.assert_array_equal(result, expected)

    def test_unordered_intervals(self):
        A = [[1, 10]]
        B = [[6, 9], [2, 5]]
        result = interval_intersection(A, B)
        expected = np.array([[2, 5], [6, 9]])
        np.testing.assert_array_equal(result, expected)


if __name__ == "__main__":
    unittest.main()
