import json
import os
import urllib.request


def handler(event, context):
    webhook_url = os.environ["SLACK_WEBHOOK_URL"]

    for record in event["Records"]:
        sns_message = json.loads(record["Sns"]["Message"])
        alarm_name = sns_message.get("AlarmName", "")
        new_state = sns_message.get("NewStateValue", "")
        reason = sns_message.get("NewStateReason", "")

        text = (
            f":warning: *CloudWatch Alarm*\n"
            f"*アラーム名*: {alarm_name}\n"
            f"*状態*: {new_state}\n"
            f"*理由*: {reason}"
        )
        payload = json.dumps({"text": text}).encode()
        req = urllib.request.Request(
            webhook_url,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req) as res:
            return {"statusCode": res.status}