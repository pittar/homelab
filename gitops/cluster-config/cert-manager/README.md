# Cert-Manager Operator

To use the Route53 instance, you will need a `route53.env` file in a `files` dir.

Specifically:

```
cert-manager/files/route53.env
```

The `kusotmization.yaml` file under `instances/route53` references this file.  It expects the following key/value pairs to be preseent:

```
access-key-id=<aws access key id>
secret-access-key=<aws secret access key>
```