import sys
import yaml

all_vars_string = sys.argv[1:2][0]
var_name = sys.argv[2:3][0]
all_vars = {}

try:
  all_vars = dict(yaml.safe_load(all_vars_string))
except:
  pass

if var_name in all_vars:
  yaml.dump({var_name: all_vars[var_name]}, sys.stdout)
