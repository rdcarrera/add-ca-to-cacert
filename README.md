# add-ca-to-cacert
Add ca certificate to Java Keystore

# Description
This container is dedicated to add ca certificates from a folder to the Java cacerts (from the default openjdk cacerts, for now)
If you've a self signed ca certificate and you want to validate it on Java this could be help you, or if you want to avoid problems with the SSL Handshake.

# How to use it

## As init container
You can use it as initContainer on your deployment/Statefulset/... througth a volume to share the cacert, for example:

### Certificate declaration as configMap
```
---
kind: ConfigMap
metadata:
  name: a-ca-certificate
data:
  ca.pem: |-
    -----BEGIN CERTIFICATE-----
    fooooooo
    ......
    fooooooo
    -----END CERTIFICATE-----
```

### Volumes declaration
```
      volumes:
      - configMap:
          defaultMode: 420
          name: a-ca-certificate
        name: a-ca-certificate
      - emptyDir: {}
        name: cacerts-binary
```

### Init Container declaration
```
    initContainers:
      - name: trust-ca-certificate
        env:
        - name: CACERT_DEST
          value: /test
        image: rdcarrera/add-ca-to-cacert
        imagePullPolicy: Always
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /test
          name: cacerts-binary
        - mountPath: /certs/ca.pem
          name: a-ca-certificate
          subPath: ca.pem
```

### Mount the volume with the cacerts within the container (RHEL family)
```
        volumeMounts:
        - mountPath: /etc/pki/ca-trust/extracted/java/cacerts
          name: cacerts-binary
          readOnly: true
          subPath: cacerts
```

# Use in the real life.

This container was created when I had the need to add a ca certificate on the keycloak container ([I used the codecentric's helm-chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloak))

So, when I configured the vars file to pass helm I added the next to work with this container (Previously I created the configmap with the certificate):

```
 extraInitContainers: |
    - name: "trust-ca-certificate"
      image: "rdcarrera/add-ca-to-cacert"
      imagePullPolicy: Always
      env:
      - name: CACERT_DEST
        value: "/test"
      volumeMounts:
      - name: cacerts-binary
        mountPath: /test
      - name: a-ca-certificate
        mountPath: /certs/ca.pem
        subPath: ca.pem

  extraVolumeMounts: |
    - name: cacerts-binary
      mountPath: /etc/pki/ca-trust/extracted/java/cacerts
      subPath: cacerts
      readOnly: true

  extraVolumes: |
    - name: a-ca-certificate
      configMap:
        name: a-ca-certificate
    - name: cacerts-binary
      emptyDir: {}
```

