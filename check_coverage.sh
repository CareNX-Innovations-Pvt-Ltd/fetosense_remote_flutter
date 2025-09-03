set -e

# Run flutter tests with coverage
flutter test --coverage

# Install lcov if missing (needed for parsing coverage)
sudo apt-get install -y lcov

# Parse total coverage %
coverage=$(lcov --summary coverage/lcov.info | grep 'lines......:' | awk '{print $2}' | sed 's/%//')

echo "Current coverage: $coverage%"

# Set required minimum coverage
required=80

coverage_int=${coverage%.*}
if [ "$coverage_int" -lt "$required" ]; then
  echo "❌ Coverage $coverage% is below required $required%"
  exit 1
else
  echo "✅ Coverage $coverage% meets requirement"
fi
