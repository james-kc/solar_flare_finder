import unittest
from typing import List
import numpy as np
from matplotlib import pyplot as plt
import inspect
from datetime import datetime, timedelta


def visualise_intersections(A: List[List[int]], B: List[List[int]]) -> None:
    """
    Visualizes the intersections of two sets of intervals on a number line.

    Parameters:
        A (List[List[int]]): A list of intervals, where each interval is represented as a list of
            two integers [start, stop].
        B (List[List[int]]): A list of intervals, where each interval is represented as a list of
            two integers [start, stop].

    Returns:
        None: This function displays a plot showing the intervals of A, B, and their overlaps.
    """

    # Get the names of the variables passed to the function
    frame = inspect.currentframe().f_back
    arg_info = inspect.getargvalues(frame)

    # Extract the variable names for A and B
    A_name = [name for name, value in arg_info.locals.items() if value is A][0]
    B_name = [name for name, value in arg_info.locals.items() if value is B][0]

    _, ax = plt.subplots(figsize=(8, 2))

    # Plot ranges for A
    for i, (start, stop) in enumerate(A):
        ax.plot([start, stop], [1, 1], color="blue", lw=6, label=A_name if i == 0 else "")

    # Plot ranges for B
    for i, (start, stop) in enumerate(B):
        ax.plot([start, stop], [2, 2], color="red", lw=6, label=B_name if i == 0 else "")

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
    ax.set_yticklabels([A_name, "Overlap", B_name])
    ax.set_xlabel("Number Line")
    ax.legend()
    ax.grid(True, axis="x")

    plt.show()


def interval_intersection(A: List[List[float]], B: List[List[float]]) -> np.ndarray:
    """
    Computes the intersection of two sets of intervals.

    Parameters:
        A (List[List[float]]): A list of intervals, where each interval is represented as a list of
            two integers [start, stop].
        B (List[List[float]]): A list of intervals, where each interval is represented as a list of
            two integers [start, stop].

    Returns:
        np.ndarray: An array of intervals that represent the intersections between A and B.
                    If there are no intersections, returns an empty array.
    """
    A = sorted(A, key=lambda x: x[0])
    B = sorted(B, key=lambda x: x[0])

    i, j = 0, 0
    result = []

    while i < len(A) and j < len(B):
        a_start, a_end = A[i]
        b_start, b_end = B[j]

        if (
            a_start <= b_end
            and b_start <= a_end
            and max(a_start, b_start) != min(a_end, b_end)  # Infinitesimal overlap handling
        ):  # Overlapping intervals
            result.append([max(a_start, b_start), min(a_end, b_end)])

        if a_end <= b_end:
            i += 1
        else:
            j += 1

    return np.array(result)


class TestIntervalIntersection(unittest.TestCase):
    """
    Unit tests for the interval_intersection function.
    """

    def test_overlapping_intervals(self):
        """
        Test case for overlapping intervals.
        """
        A = [[1, 3], [5, 9], [12, 15]]
        B = [[2, 6], [8, 10], [14, 18]]
        result = interval_intersection(A, B)
        expected = np.array([[2, 3], [5, 6], [8, 9], [14, 15]])
        np.testing.assert_array_equal(result, expected)

    def test_non_overlapping_intervals(self):
        """
        Test case for non-overlapping intervals.
        """
        A = [[1, 2], [5, 7]]
        B = [[3, 4], [8, 10]]
        result = interval_intersection(A, B)
        expected = np.array([])  # No intersections
        np.testing.assert_array_equal(result, expected)

    def test_one_list_empty(self):
        """
        Test case when one list of intervals is empty.
        """
        A = [[1, 2], [5, 7]]
        B = []
        result = interval_intersection(A, B)
        expected = np.array([])  # No intersections since B is empty
        np.testing.assert_array_equal(result, expected)

    def test_both_lists_empty(self):
        """
        Test case when both lists of intervals are empty.
        """
        A = []
        B = []
        result = interval_intersection(A, B)
        expected = np.array([])  # No intersections since both are empty
        np.testing.assert_array_equal(result, expected)

    def test_enclosing_intervals(self):
        """
        Test case for intervals where one interval encloses others.
        """
        A = [[1, 10]]
        B = [[2, 5], [6, 9]]
        result = interval_intersection(A, B)
        expected = np.array([[2, 5], [6, 9]])
        np.testing.assert_array_equal(result, expected)

    def test_unordered_intervals(self):
        """
        Test case for unordered intervals.
        """
        A = [[1, 10]]
        B = [[6, 9], [2, 5]]
        result = interval_intersection(A, B)
        expected = np.array([[2, 5], [6, 9]])
        np.testing.assert_array_equal(result, expected)

    def test_infinitesimal_overlap(self):
        """
        Test case for intervals where an end value equals a start value.
        """
        A = [[1, 2]]
        B = [[2, 3]]
        result = interval_intersection(A, B)
        expected = np.array([])
        np.testing.assert_array_equal(result, expected)


def fractional_overlap(
    obs_start: datetime,
    obs_end: datetime,
    flare_start: datetime,
    flare_peak: datetime,
    flare_end: datetime,
) -> tuple:
    """
    Calculate the fractional overlap between an observation period and a flare period.

    Parameters:
        obs_start: Start time of observation period
        obs_end: End time of observation period
        flare_start: Start time of flare
        flare_end: End time of flare
        flare_peak: Peak time of flare

    Returns:
        tuple: (frac_obs, frac_obs_rise, frac_obs_fall)
               frac_obs: Fractional overlap (0 to 1) relative to the flare duration
               frac_obs_rise: Fractional overlap during the rise phase (start to peak)
               frac_obs_fall: Fractional overlap during the fall phase (peak to end)
    """
    if not (flare_start < flare_peak < flare_end):
        raise ValueError("flare_start < flare_peak < flare_end must be true")

    overlap_start = max(obs_start, flare_start)
    overlap_end = min(obs_end, flare_end)

    overlap_duration = max(timedelta(0), overlap_end - overlap_start)
    flare_duration = flare_end - flare_start
    rise_duration = flare_peak - flare_start
    fall_duration = flare_end - flare_peak

    frac_obs = overlap_duration / flare_duration
    frac_obs_rise = (
        max(timedelta(0), min(overlap_end, flare_peak) - overlap_start) / rise_duration
        if rise_duration > timedelta(0)
        else 0.0
    )
    frac_obs_fall = (
        max(timedelta(0), overlap_end - max(overlap_start, flare_peak)) / fall_duration
        if fall_duration > timedelta(0)
        else 0.0
    )

    return frac_obs, frac_obs_rise, frac_obs_fall


if __name__ == "__main__":
    unittest.main()
