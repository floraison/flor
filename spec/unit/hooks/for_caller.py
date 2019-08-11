
import sys
import json

message = sys.stdin.read()
message = json.loads(message)

message["point"] = "receive"
message["payload"]["price"] = "CHF 5.00"

if len(sys.argv) > 1:
  message["argument"] = sys.argv[1]

print json.dumps(message)

