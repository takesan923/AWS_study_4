# minikube 起動

```
minikube start
```

---

# イメージをビルドして minikube に渡す

```
eval $(minikube docker-env)
docker build -t api:local ./challenge4-1/Backend
```

---

# Deployment + Service を apply

```
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

# ブラウザで確認

```
minikube service api-service
```

# データフロー

```mermaid
flowchart TB
Postman(["Postman\nhttp://127.0.0.1:54734"])

subgraph minikube["minikube (Node)"]
    subgraph secret["Secret: mysql-secret"]
        S1["db-user\ndb-password\nroot-password"]
    end

    subgraph api_group["Deployment: api"]
        API["Pod: api\nimage: api:local\nport: 8080\nreadinessProbe: /health"]
    end

    subgraph svc_api["Service: api-service (NodePort)"]
        SVC_API["port: 8080\nselector: app=api"]
    end

    subgraph mysql_group["StatefulSet: mysql"]
        MYSQL["Pod: mysql-0\nimage: mysql:8.0\nport: 3306"]
    end

    subgraph svc_mysql["Service: mysql (Headless)"]
        SVC_MYSQL["clusterIP: None\nselector: app=mysql"]
    end

    PVC[("PVC: mysql-data-mysql-0\n1Gi")]
end

Postman -->|"NodePort"| SVC_API
SVC_API -->|"selector: app=api"| API
API -->|"DB_HOST=mysql\nDNS解決"| SVC_MYSQL
SVC_MYSQL -->|"selector: app=mysql"| MYSQL
MYSQL -->|"volumeMount\n/var/lib/mysql"| PVC
secret -->|"env 参照"| API
secret -->|"env 参照"| MYSQL
```
