import sys
import yaml

source_vars_string = sys.argv[1:2][0]
target_vars_string = sys.argv[2:3][0]

source_vars = dict(yaml.safe_load(source_vars_string))

target_vars = {}
try:
  target_vars = dict(yaml.safe_load(target_vars_string))
except:
  pass

for k in source_vars:
  if k in target_vars:
    yaml.dump({k: target_vars[k]}, sys.stdout)
    continue

  yaml.dump({k: source_vars[k]}, sys.stdout)
