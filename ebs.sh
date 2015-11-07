#!/usr/bin/env bash
set -x
instance_id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
if [ $? -ne 0 ]; then echo "Failed to lookup instance id"; exit 1; fi

AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

[ -z "$AWS_ACCESS_KEY_ID" ] && echo "AWS_ACCESS_KEY_ID not set" && exit 1;
[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "AWS_ACCESS_KEY_ID not set" && exit 1;
[ -z "$DEVICE" ] && echo "DEVICE not set" && exit 1;

function volume_state {
  aws --output=text ec2 describe-volumes --volume-ids "$VOLUME_ID" \
    | grep ^VOLUMES \
    | cut -f8
}

function volume_instance {
  aws --output=text ec2 describe-volumes --volume-ids "$VOLUME_ID" \
    | grep ^ATTACHMENTS \
    | cut -f5
}

function volume_device {
  aws --output=text ec2 describe-volumes --volume-ids "$VOLUME_ID" \
    | grep ^ATTACHMENTS \
    | cut -f4
}

function wait_state {
  echo "Waiting for state $1"
  while [ ! "$(volume_state)" = "$1" ]; do
    volume_state
    sleep 1
  done
}

function attach {
  echo "Attaching volume ${VOLUME_ID} to ${instance_id} : ${DEVICE}..."

  aws ec2 attach-volume \
    --volume-id "$VOLUME_ID" \
    --instance-id "$instance_id" \
    --device "$DEVICE" || exit "$?"

  wait_state "in-use"
}

function detach {
  echo "Detaching volume ${VOLUME_ID} from ${instance_id} : ${DEVICE}..."
  [ "$(volume_state)" = "available" ] && echo "Already detached" && exit 0;

  if [ "$1" = "--force" ]; then
    instance_id=$(volume_instance)
    DEVICE=$(volume_device)
  fi

  aws ec2 detach-volume \
    --volume-id "$VOLUME_ID" \
    --instance-id "$instance_id" \
    --device "$DEVICE" || exit "$?"

  wait_state "available"
}

$1 "$2"