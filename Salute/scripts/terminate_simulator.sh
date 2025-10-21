#!/bin/bash
set -uo pipefail

BUNDLE_ID="com.ShashaankShankar.Salute"

if xcrun simctl terminate booted "${BUNDLE_ID}"; then
  echo "Terminated ${BUNDLE_ID} on the booted simulator."
else
  echo "Simulator did not have ${BUNDLE_ID} running."
fi
