# Exact / anchor points
./bin/tempconv 0 --c-to-f       # 0 C -> 32 F
echo "actual"
echo "0 C -> 32 F"
echo "expected"
echo ""
./bin/tempconv 100 --c-to-f     # 100 C -> 212 F
echo "actual"
echo "100 C -> 212 F"
echo "expected"
echo ""
./bin/tempconv 32 --f-to-c      # 32 F -> 0 C
echo "actual"
echo "32 F -> 0 C"
echo "expected"
echo ""
./bin/tempconv 212 --f-to-c     # 212 F -> 100 C
echo "actual"
echo "212 F -> 100 C"
echo "expected"
echo ""
./bin/tempconv -40 --c-to-f     # -40 C -> -40 F
echo "actual"
echo "-40 C -> -40 F"
echo "expected"
echo ""
./bin/tempconv -40 --f-to-c     # -40 F -> -40 C
echo "actual"
echo "-40 F -> -40 C"
echo "expected"
echo ""

# Positive values that require rounding
./bin/tempconv 1 --c-to-f       # 1 C -> 34 F       (33.8)
echo "actual"
echo "1 C -> 34 F"
echo "expected"
echo ""
./bin/tempconv 2 --c-to-f       # 2 C -> 36 F       (35.6)
echo "actual"
echo "2 C -> 36 F"
echo "expected"
echo ""
./bin/tempconv 33 --f-to-c      # 33 F -> 1 C       (~0.56)
echo "actual"
echo "33 F -> 1 C"
echo "expected"
echo ""
./bin/tempconv 34 --f-to-c      # 34 F -> 1 C       (~1.11)
echo "actual"
echo "34 F -> 1 C"
echo "expected"
echo ""

# Negative values that require rounding
./bin/tempconv -1 --c-to-f      # -1 C -> 30 F      (30.2)
echo "actual"
echo "-1 C -> 30 F"
echo "expected"
echo ""
./bin/tempconv -2 --c-to-f      # -2 C -> 28 F      (28.4)
echo "actual"
echo "-2 C -> 28 F"
echo "expected"
echo ""
./bin/tempconv 31 --f-to-c      # 31 F -> -1 C      (~-0.56)
echo "actual"
echo "31 F -> -1 C"
echo "expected"
echo ""
./bin/tempconv 30 --f-to-c      # 30 F -> -1 C      (~-1.11)
echo "actual"
echo "30 F -> -1 C"
echo "expected"
echo ""

# Special cases
./bin/tempconv 33 --f-to-c      # 33 F -> 1 C
echo "actual"
echo "33 F -> 1 C"
echo "expected"
echo ""
./bin/tempconv 31 --f-to-c      # 31 F -> -1 C
echo "actual"
echo "31 F -> -1 C"
echo "expected"
