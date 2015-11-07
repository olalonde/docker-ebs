#!/usr/bin/env bash
instance_id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
if [ $? -ne 0 ]; then echo "Failed to lookup instance id"; exit 1; fi

function attach {
  echo "Attaching volume ${VOLUME_ID} to ${instance_id} : ${DEVICE}..."

  aws ec2 attach-volume \
    --volume-id "$VOLUME_ID" \
    --instance-id "$instance_id" \
    --device "$DEVICE" || exit "$?"

  # wait for attached state...

  wait
}

function detach {
  echo "Detaching volume ${VOLUME_ID} from ${instance_id} : ${DEVICE}..."

  aws ec2 detach-volume \
    --volume-id "$VOLUME_ID" \
    --instance-id "$instance_id" \
    --device "$DEVICE"

  exit "$?"
}

function cleanup {
  detach
}

trap cleanup INT TERM

attach