docker-ebs attaches an AWS EBS volume to the EC2 instance where the
container is started.

See
[http://github.com/olalonde/coreos-bitcoind](http://github.com/olalonde/coreos-bitcoind)
for example usage with CoreOS.

# Usage

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=<key> \
  -e AWS_SECRET_ACCESS_KEY=<secret> \
  -e AWS_DEFAULT_REGION=<region> \
  -e VOLUME_ID=<volume_id> \
  -e DEVICE=<device> \
  olalond3/ebs <command>
```

command: attach, detach, detach --force
