
import sys
import json

message = sys.stdin.read()
message = json.loads(message)

message["payload"]["price"] = "CHF 5.00"

print json.dumps(message)

