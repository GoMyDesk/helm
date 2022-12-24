# gomydesk

A Kubernetes-Native Virtual Desktop Infrastructure

## Installation

```bash
$> helm repo add gomydesk https://gomydesk.github.io/helm/charts
$> helm install gomydesk gomydesk/gomydesk
```

Once the app pod is running (this may take a minute) you can retrieve the initial admin password with:

```bash
$> kubectl get secret gomydesk-admin-secret -o go-template="{{ .data.password }}" | base64 -d && echo
```

The app service by default is called `gomydesk-app` and you can retrieve the endpoint with `kubectl get svc gomydesk-app`.
If you'd like to use `port-forward` you can run:

```bash
$> kubectl port-forward svc/gomydesk-app 8443:443
```

Then visit https://localhost:8443 to use `gomydesk`.

If you'd like to see an example of the `helm` values for using vault as the secrets backend,
you can find documentation in the [examples](https://github.com/gomydesk/gomydesk/blob/main/deploy/examples/example-vault-helm-values.yaml) folder.
There are examples for LDAP and OIDC authentication in the same folder.

For an up-to-date and complete list of all available options see the [API Reference](https://github.com/gomydesk/gomydesk/blob/main/doc/appv1.md#VDIClusterSpec).

### Enabling Metrics

By default the `gomydesk-app` pods will provide prometheus metrics at `/api/metrics`. In addition to this,
you can configure the `gomydesk-manager` to manage the `prometheus-operator` resources required to scrape those metrics.

For the time being, the grafana implementation will only work if you let `gomydesk` also create the `Prometheus` CR.
Alternatively, you can let `gomydesk` create the `ServiceMonitor` with labels selected by your existing prometheus instances, and use
the [example dashboard](https://github.com/gomydesk/gomydesk/blob/main/deploy/examples/example-grafana-dashboard.json) as a starting point in grafana.

To enable the in-UI metrics you can do the following:

```bash
# The values in the hack/ directory will disable everything in the helm chart except the operator
helm install prometheus-operator stable/prometheus-operator -f hack/prom-operator-values.yaml

# Follow the instructions above to set up the gomydesk repo and then pass the metrics arguments:
helm install gomydesk gomydesk/gomydesk \
    --set vdi.spec.metrics.serviceMonitor.create=true \
    --set vdi.spec.metrics.prometheus.create=true \
    --set vdi.spec.metrics.grafana.enabled=true
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` | A full name override for resources created by the chart. |
| ingress.annotations."cert-manager.io/cluster-issuer" | string | `"letsencrypt-prod"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/backend-protocol" | string | `"HTTPS"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"50m"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hostname | string | `"desktop.gomydesk.com"` |  |
| ingress.ingressClassName | string | `"nginx"` |  |
| ingress.tls | bool | `true` |  |
| manager.affinity | object | `{}` | Node affinity for the manager pod. |
| manager.image.pullPolicy | string | `"IfNotPresent"` | The `ImagePullPolicy` to use for the manager pod. |
| manager.image.repository | string | `"ghcr.io/gomydesk/manager"` | The repository and image for the manager. |
| manager.image.tag | string | `""` | The tag for the manager image. Defaults to the chart version. |
| manager.imagePullSecrets | list | `[]` | Image pull secrets for the manager pod. |
| manager.nodeSelector | object | `{}` | Node selectors for the manager pod. |
| manager.podSecurityContext | object | `{}` | The `PodSecurityContext` for the manager pod. |
| manager.replicaCount | int | `1` | The number of manager replicas to run. If more than one is set, they will run in active/standby mode. |
| manager.resources | object | `{}` | Resource limits for the manager pod. |
| manager.securityContext | object | `{}` | The container security context for the manager pod. |
| manager.tolerations | list | `[]` | Node tolerations for the manager pod. |
| nameOverride | string | `""` | A name override for resources created by the chart. |
| rbac.proxy | object | `{"repository":"gcr.io/kubebuilder/kube-rbac-proxy","tag":"v0.5.0"}` | RBAC Proxy configurations for the manager deployment |
| rbac.proxy.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` | The repository to pull the kube-rbac-proxy image from |
| rbac.proxy.tag | string | `"v0.5.0"` | The tag to pull for the kube-rbac-proxy. |
| rbac.serviceAccount.create | bool | `true` | Specifies whether a `ServiceAccount` should be created. |
| rbac.serviceAccount.name | string | If not set and create is true, a name is generated using the fullname template. | The name of the `ServiceAccount` to use. |
| vdi.labels | object | `{"component":"gomydesk-cluster"}` | Extra labels to apply to gomydesk related resources. |
| vdi.spec | object | The values described below are the same as the `VDICluster` CRD defaults. | The `VDICluster` spec. |
| vdi.spec.app | object | The values described below are the same as the `VDICluster` CRD defaults. | App level configurations for `gomydesk`. |
| vdi.spec.app.auditLog | bool | `false` | Enables a detailed audit log of API events. At the moment, these just get logged to stdout on the app instance. |
| vdi.spec.app.replicas | int | `1` | The number of app replicas to run. |
| vdi.spec.app.resources | object | `{}` | Resource limits for the app pods. |
| vdi.spec.app.serviceAnnotations | object | `{}` | Extra annotations to place on the gomydesk app service. |
| vdi.spec.app.serviceType | string | `"ClusterIP"` | The type of service to create in front of the app instance. |
| vdi.spec.app.tls | object | `{"serverSecret":""}` | TLS configurations for the app instance. |
| vdi.spec.app.tls.serverSecret | string | `""` | A pre-existing TLS secret to use for the HTTPS listener on the app instance. If not provided, one is generated for you. |
| vdi.spec.appNamespace | string | `"default"` | The namespace where the `gomydesk` app will run. This is different than the chart namespace. The chart lays down the manager and a VDI configuration, and the manager takes care of the rest. |
| vdi.spec.auth | object | The values described below are the same as the `VDICluster` CRD defaults. | Authentication configurations for `gomydesk`. |
| vdi.spec.auth.adminSecret | string | `"gomydesk-admin-secret"` | The secret to store the generated admin password in. |
| vdi.spec.auth.allowAnonymous | bool | `false` | Allow anonymous users to launch and use desktops. |
| vdi.spec.auth.ldapAuth | object | `{}` | Use an LDAP server for the authentication backend. See the [API reference](../../../doc/crds.md#LDAPConfig) for available configurations. |
| vdi.spec.auth.localAuth | object | `{}` | Use local-auth for the authentication backend. This is the default configuration. |
| vdi.spec.auth.oidcAuth | object | `{}` | Use an OpenID/Oauth provider for the authentication backend. See the [API reference](../../../doc/crds.md#OIDCConfig) for available configurations. |
| vdi.spec.auth.tokenDuration | string | `"15m"` | The time-to-live for access tokens issued to users. If using OIDC/Oauth, you probably want to set this to a higher value, since refreshing tokens is currently not supported. |
| vdi.spec.desktops | object | `{"maxSessionLength":""}` | Global configurations for desktop sessions. |
| vdi.spec.desktops.maxSessionLength | string | `""` | When configured, desktop sessions will be terminated after running for the specified period of time. Values are in duration formats (e.g. `3m`, `2h`, `1d`). |
| vdi.spec.imagePullSecrets | list | `[]` | Image pull secrets to use for app containers. |
| vdi.spec.metrics | object | `{"serviceMonitor":{"create":true,"labels":{"release":"prometheus"}}}` | Metrics configurations for `gomydesk`. |
| vdi.spec.metrics.serviceMonitor | object | `{"create":true,"labels":{"release":"prometheus"}}` | Configurations for creating a ServiceMonitor object to scrape `gomydesk` metrics. |
| vdi.spec.metrics.serviceMonitor.create | bool | `true` | Set to true to have `gomydesk` create a ServiceMonitor. There is an example dashboard in the [examples](../../examples/example-grafana-dashboard.json) directory. |
| vdi.spec.metrics.serviceMonitor.labels | object | `{"release":"prometheus"}` | Extra labels to apply to the ServiceMonitor object. |
| vdi.spec.secrets | object | The values described below are the same as the `VDICluster` CRD defaults. | Secret storage configurations for `gomydesk`. |
| vdi.spec.secrets.k8sSecret | object | `{"secretName":"gomydesk-app-secrets"}` | Use the Kubernetes secret storage backend. This is the default if no other configuration is provided. For now, see the API reference for what to use in place of these values if using a different backend. |
| vdi.spec.secrets.k8sSecret.secretName | string | `"gomydesk-app-secrets"` | The name of the Kubernetes `Secret`. backing the secret storage. |
| vdi.spec.secrets.vault | object | `{}` | Use vault for the secret storage backend. See the [API reference](../../../doc/crds.md#VaultConfig) for available configurations. |
| vdi.spec.userdataSpec | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1G"}},"storageClassName":"efs-sc"}` | If configured, enables userdata persistence with the given PVC spec. Every user will receive their own PV with the provided configuration. |
| vdi.templates | list | `[]` | Preload DesktopTemplates into the VDI Cluster. You only need to define the `metadata` and `spec`. Namespaces can be ignored sinced DesktopTemplates are cluster-scoped. |
