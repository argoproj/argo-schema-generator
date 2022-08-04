### Description
This repo contains a tool that generates a kustomize schema file for native kubernetes resources plus projects under the 
argoproj name including Argo CD, Argo Rollouts, Argo Workflows, and Argo Events.

### How to run
To run the tool, run the following command:
```
make gen-openapi-schema
```

### How to use
In your kustomization.yaml file add a config block like

```
openapi:
  path: https://raw.githubusercontent.com/zachaller/argo-schema-generator/main/schema/argo_all_k8s_kustomize_schema.json
```

### Github Action
There is a Github action set to run on the first of each month that will update the schema's. This action can 
also be manually run to update definitions.