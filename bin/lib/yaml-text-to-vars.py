import sys
import yaml

yaml_lines = ""
for line in sys.stdin:
  yaml_lines += str(line)

try:
  vars = dict(yaml.safe_load(yaml_lines))
  yaml.dump(vars, sys.stdout)
except:
  pass
