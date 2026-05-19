---
name: k8s-deployment-template
description: Kubernetes Deployment + Service + Ingress + HPA + PDB 完整资源模板
---

# Kubernetes 部署模板

## Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ app-name }}
  labels:
    app.kubernetes.io/name: {{ app-name }}
    app.kubernetes.io/version: {{ version }}
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ app-name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ app-name }}
        app.kubernetes.io/version: {{ version }}
    spec:
      serviceAccountName: {{ app-name }}
      terminationGracePeriodSeconds: 30
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app.kubernetes.io/name: {{ app-name }}
                topologyKey: kubernetes.io/hostname
      containers:
        - name: {{ app-name }}
          image: {{ registry }}/{{ image }}:{{ tag }}
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
          envFrom:
            - configMapRef:
                name: {{ app-name }}-config
            - secretRef:
                name: {{ app-name }}-secrets
```

## Service + Ingress + HPA + PDB

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: {{ app-name }}
spec:
  selector:
    app.kubernetes.io/name: {{ app-name }}
  ports:
    - port: 80
      targetPort: 3000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ app-name }}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
    - hosts: [{{ domain }}]
      secretName: {{ app-name }}-tls
  rules:
    - host: {{ domain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ app-name }}
                port:
                  number: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ app-name }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ app-name }}
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ app-name }}
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ app-name }}
```
