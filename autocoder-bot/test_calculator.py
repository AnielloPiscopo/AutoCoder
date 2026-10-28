import unittest
from calculator import add, subtract, multiply, divide

class TestCalculator(unittest.TestCase):

    def test_add(self):
        self.assertAlmostEqual(add(1.5, 2.5), 4.0)
        self.assertAlmostEqual(add(-1, -2), -3)

    def test_subtract(self):
        self.assertAlmostEqual(subtract(5, 3), 2)
        self.assertAlmostEqual(subtract(0, 5), -5)

    def test_multiply(self):
        self.assertAlmostEqual(multiply(2, 3), 6)
        self.assertAlmostEqual(multiply(-1, 5), -5)

    def test_divide(self):
        self.assertAlmostEqual(divide(10, 2), 5)
        self.assertAlmostEqual(divide(5, 2), 2.5)

    def test_divide_by_zero(self):
        with self.assertRaises(ValueError):
            divide(1, 0)

if __name__ == '__main__':
    unittest.main()
