### Description
This repo contains a tool that generates a kustomize schema file for native kubernetes resources plus projects under the 
argoproj name including Argo CD, Argo Rollouts, Argo Workflows, and Argo Events.

### How to run
To run the tool, run the following command:
```
make gen-schema
```

### How to use
In your kustomization.yaml file add a config block like

```
openapi:
  path: https://raw.githubusercontent.com/zachaller/argo-schema-generator/main/schema/argo_all_k8s_kustomize_schema.json
```