
import os
import sys
import json

#
# input (stdin)

message = sys.stdin.read()
message = json.loads(message)

message["point"] = "receive"
message["payload"]["price"] = "CHF 5.00"

#
# other inputs

if len(sys.argv) > 1: message["argument"] = sys.argv[1]

fcv = os.environ.get('ENV_VAR')
if fcv: message["env_var"] = fcv

#
# output

print(json.dumps(message))

